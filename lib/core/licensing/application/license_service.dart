import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/hardware_fingerprint_service.dart';
import '../data/license_crypto_service.dart';
import '../domain/license_info.dart';

part 'license_service.g.dart';

@Riverpod(keepAlive: true)
class LicenseService extends _$LicenseService {
  static const String _prefTokenKey = 'farmsys_license_token';
  static const String _prefClockKey = 'farmsys_license_clock_watermark';
  static const String _prefLegacyPremium = 'is_premium_license';

  @override
  FutureOr<LicenseInfo> build() async {
    return _checkLocalLicense();
  }

  /// Lee y valida la licencia instalada en la máquina local
  Future<LicenseInfo> _checkLocalLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final machineId = await HardwareFingerprintService.getMachineId();

    final savedToken = prefs.getString(_prefTokenKey);
    final savedClockStr = prefs.getString(_prefClockKey);
    final lastSeenClock =
        savedClockStr != null ? DateTime.tryParse(savedClockStr) : null;

    if (savedToken != null && savedToken.trim().isNotEmpty) {
      final result = LicenseCryptoService.validateToken(
        rawToken: savedToken,
        currentMachineId: machineId,
        lastSeenClock: lastSeenClock,
      );

      if (result.isSuccess && result.licenseInfo != null) {
        // Actualizamos la marca de agua del reloj para evitar atrasos intencionales
        await prefs.setString(
          _prefClockKey,
          DateTime.now().toIso8601String(),
        );
        return result.licenseInfo!;
      } else if (result.isTampered && result.licenseInfo != null) {
        return result.licenseInfo!;
      }
    }

    // Aprovisionamiento automático de Licencia Trial de 15 días en primera instalación
    final autoTrialProvisioned = prefs.getBool('farmsys_auto_trial_provisioned') ?? false;
    if (!autoTrialProvisioned && (savedToken == null || savedToken.trim().isEmpty)) {
      final now = DateTime.now();
      final validUntil = now.add(const Duration(days: 15));
      final trialToken = LicenseCryptoService.generateSignedToken(
        ruc: '9999999999999',
        businessName: 'Farmacia Demostración',
        machineId: machineId,
        validUntil: validUntil,
        tier: LicenseTier.trial,
        issuedAt: now,
      );

      await prefs.setString(_prefTokenKey, trialToken);
      await prefs.setString(_prefClockKey, now.toIso8601String());
      await prefs.setBool('farmsys_auto_trial_provisioned', true);

      final result = LicenseCryptoService.validateToken(
        rawToken: trialToken,
        currentMachineId: machineId,
      );
      if (result.isSuccess && result.licenseInfo != null) {
        return result.licenseInfo!;
      }
    }

    // Retrocompatibilidad con desarrollo / pruebas tempranas
    final isLegacyPremium = prefs.getBool(_prefLegacyPremium) ?? false;
    if (isLegacyPremium) {
      return LicenseInfo(
        tier: LicenseTier.premium,
        status: LicenseStatus.active,
        licenseKey: 'PREMIUM-FARMSYS',
        ruc: '1799999999001',
        businessName: 'Farmacia Demostración',
        machineId: machineId,
        issuedAt: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 365)),
        lastVerifiedAt: DateTime.now(),
        features: const ['*'],
        isValid: true,
      );
    }

    // Si no hay licencia activa registrada
    return LicenseInfo.unlicensed(machineId: machineId);
  }

  /// Activa una licencia en este equipo mediante el código o token firmado
  Future<LicenseInfo> activateLicense(String rawToken) async {
    state = const AsyncLoading();

    try {
      final machineId = await HardwareFingerprintService.getMachineId();
      final prefs = await SharedPreferences.getInstance();

      final savedClockStr = prefs.getString(_prefClockKey);
      final lastSeenClock =
          savedClockStr != null ? DateTime.tryParse(savedClockStr) : null;

      final result = LicenseCryptoService.validateToken(
        rawToken: rawToken,
        currentMachineId: machineId,
        lastSeenClock: lastSeenClock,
      );

      if (!result.isSuccess || result.licenseInfo == null) {
        throw Exception(
          result.errorMessage ?? 'La clave de licencia proporcionada no es válida.',
        );
      }

      final info = result.licenseInfo!;

      // Guardamos el token en SharedPreferences
      await prefs.setString(_prefTokenKey, rawToken.trim());
      await prefs.setString(_prefClockKey, DateTime.now().toIso8601String());
      await prefs.setBool(_prefLegacyPremium, info.isPremium);

      state = AsyncData(info);
      return info;
    } catch (e) {
      state = AsyncData(await _checkLocalLicense());
      rethrow;
    }
  }

  /// Retrocompatibilidad para diálogo existente
  Future<void> activatePremiumLicense(String licenseKey) async {
    await activateLicense(licenseKey);
  }

  /// Desvincula la licencia local de este equipo
  Future<void> deactivateLicense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefTokenKey);
    await prefs.remove(_prefLegacyPremium);

    final machineId = await HardwareFingerprintService.getMachineId();
    state = AsyncData(LicenseInfo.unlicensed(machineId: machineId));
  }

  /// Retorna la huella digital del equipo
  Future<String> getMachineId() async {
    return HardwareFingerprintService.getMachineId();
  }

  /// Re-valida el estado actual (ej. al abrir la app o regresar de hibernación)
  Future<void> refresh() async {
    state = AsyncData(await _checkLocalLicense());
  }
}
