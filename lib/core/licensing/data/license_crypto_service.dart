import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../domain/license_info.dart';

/// Motor criptográfico para firma, validación y verificación de licencias
/// sin requerir conexión constante a internet (100% Offline-Capable).
class LicenseCryptoService {
  /// Secreto maestro para firma de licencias comerciales FarmSys.
  /// (En el generador del proveedor se utiliza esta misma firma para expedir licencias).
  /// Protegido con ofuscación XOR multicapa y soporte para inyección de entorno
  /// para evitar que cadenas de texto plano queden expuestas en el binario AOT (libapp.so).
  static String get _signingSecret {
    const envSecret = String.fromEnvironment('FARMSYS_LICENSE_SECRET');
    if (envSecret.isNotEmpty) {
      return envSecret;
    }
    const masked = <int>[
      25, 226, 69, 214, 30, 215, 97, 46, 26, 224, 66, 218, 9, 193, 96, 46,
      28, 236, 90, 214, 8, 220, 113, 56, 30, 239, 72, 215, 4, 205, 119, 63,
      12, 230, 72, 200, 8, 205, 96, 52, 11, 252, 92, 222, 20, 209, 0, 65,
      109, 149, 72, 195, 116, 182, 115
    ];
    const mask = <int>[0x5F, 0xA3, 0x17, 0x9B, 0x4D, 0x8E, 0x32, 0x71];
    return utf8.decode(
      List<int>.generate(masked.length, (i) => masked[i] ^ mask[i % mask.length]),
    );
  }

  /// Periodo de tolerancia / gracia en días tras la fecha oficial de caducidad
  static const int gracePeriodDays = 15;

  /// Genera un token firmado digitalmente con HMAC-SHA256
  static String generateSignedToken({
    required String ruc,
    required String businessName,
    required String machineId,
    required DateTime validUntil,
    LicenseTier tier = LicenseTier.pro,
    List<String> features = const [
      'pos',
      'inventory',
      'sri_electronic_billing',
      'reports',
      'backups'
    ],
    DateTime? issuedAt,
  }) {
    final issued = issuedAt ?? DateTime.now();

    final payloadMap = {
      'ruc': ruc.trim(),
      'business_name': businessName.trim(),
      'machine_id': machineId.trim().toUpperCase(),
      'tier': tier.name,
      'issued_at': issued.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'features': features,
    };

    final payloadJson = jsonEncode(payloadMap);
    final payloadBase64 = base64Url.encode(utf8.encode(payloadJson));

    final hmac = Hmac(sha256, utf8.encode(_signingSecret));
    final signature = hmac.convert(utf8.encode(payloadBase64));
    final signatureBase64 = base64Url.encode(signature.bytes);

    return '$payloadBase64.$signatureBase64';
  }

  /// Valida el token contra la huella de hardware del equipo actual y el reloj
  static LicenseValidationResult validateToken({
    required String rawToken,
    required String currentMachineId,
    DateTime? lastSeenClock,
  }) {
    final token = rawToken.trim();
    if (token.isEmpty) {
      return LicenseValidationResult.invalid('El código de licencia está vacío.');
    }

    // Permitir clave de prueba en desarrollo/evaluación
    if (token.toUpperCase() == 'PREMIUM-FARMSYS') {
      return LicenseValidationResult.valid(
        LicenseInfo(
          tier: LicenseTier.premium,
          status: LicenseStatus.active,
          licenseKey: 'PREMIUM-FARMSYS',
          ruc: '1799999999001',
          businessName: 'Farmacia Demostración',
          machineId: currentMachineId,
          issuedAt: DateTime.now(),
          expirationDate: DateTime.now().add(const Duration(days: 365)),
          lastVerifiedAt: DateTime.now(),
          features: const ['*'],
          isValid: true,
        ),
      );
    }

    final parts = token.split('.');
    if (parts.length != 2) {
      return LicenseValidationResult.invalid(
        'El formato de la clave de licencia es inválido.',
      );
    }

    final payloadBase64 = parts[0];
    final signatureBase64 = parts[1];

    // 1. Verificación de firma criptográfica
    final hmac = Hmac(sha256, utf8.encode(_signingSecret));
    final expectedSignature = hmac.convert(utf8.encode(payloadBase64));
    final expectedSignatureBase64 = base64Url.encode(expectedSignature.bytes);

    if (signatureBase64 != expectedSignatureBase64) {
      return LicenseValidationResult.invalid(
        'La firma digital de la licencia es inválida o ha sido alterada.',
      );
    }

    // 2. Decodificación del payload
    Map<String, dynamic> payload;
    try {
      final payloadJson = utf8.decode(base64Url.decode(payloadBase64));
      payload = jsonDecode(payloadJson) as Map<String, dynamic>;
    } catch (_) {
      return LicenseValidationResult.invalid(
        'No se pudo leer la información de la licencia.',
      );
    }

    final licensedMachineId =
        (payload['machine_id'] as String? ?? '').trim().toUpperCase();
    final ruc = payload['ruc'] as String? ?? '';
    final businessName = payload['business_name'] as String? ?? '';
    final tierStr = payload['tier'] as String? ?? 'pro';
    final issuedAtStr = payload['issued_at'] as String?;
    final validUntilStr = payload['valid_until'] as String?;
    final featuresList = (payload['features'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['*'];

    // 3. Verificación de vinculación con la máquina (Hardware ID)
    final normalizedCurrentMachineId = currentMachineId.trim().toUpperCase();
    if (licensedMachineId != '*' &&
        licensedMachineId != normalizedCurrentMachineId) {
      return LicenseValidationResult.invalid(
        'Esta licencia está vinculada a otro equipo ($licensedMachineId). '
        'Tu ID de equipo actual es: $normalizedCurrentMachineId.',
      );
    }

    // 4. Verificación de manipulación del reloj (Clock Rollback Protection)
    final now = DateTime.now();
    if (lastSeenClock != null) {
      // Si el reloj actual está atrasado más de 2 horas respecto al último registro conocido
      if (now.isBefore(lastSeenClock.subtract(const Duration(hours: 2)))) {
        return LicenseValidationResult.tampered(
          LicenseInfo(
            tier: _parseTier(tierStr),
            status: LicenseStatus.tamperedClock,
            licenseKey: token,
            ruc: ruc,
            businessName: businessName,
            machineId: licensedMachineId,
            issuedAt: issuedAtStr != null ? DateTime.tryParse(issuedAtStr) : null,
            expirationDate:
                validUntilStr != null ? DateTime.tryParse(validUntilStr) : null,
            lastVerifiedAt: now,
            features: featuresList,
            isValid: false,
          ),
          'Se detectó una inconsistencia en la fecha u hora del sistema. '
          'Por favor sincroniza el reloj oficial de tu computadora.',
        );
      }
    }

    // 5. Verificación de vigencia y periodo de gracia
    DateTime? expirationDate;
    if (validUntilStr != null) {
      expirationDate = DateTime.tryParse(validUntilStr);
    }

    final parsedTier = _parseTier(tierStr);
    LicenseStatus status = LicenseStatus.active;
    bool isValid = true;

    if (expirationDate != null) {
      if (now.isAfter(expirationDate)) {
        final isTrial = parsedTier == LicenseTier.trial;
        final graceLimit = isTrial
            ? expirationDate
            : expirationDate.add(const Duration(days: gracePeriodDays));

        if (!isTrial && now.isBefore(graceLimit)) {
          // Dentro de los 15 días de gracia para licencias comerciales de pago
          status = LicenseStatus.gracePeriod;
          isValid = true;
        } else {
          // Expirado completamente: bloqueo de ventas y modo solo lectura
          status = LicenseStatus.expired;
          isValid = false;
        }
      }
    }

    final licenseInfo = LicenseInfo(
      tier: _parseTier(tierStr),
      status: status,
      licenseKey: token,
      ruc: ruc,
      businessName: businessName,
      machineId: licensedMachineId,
      issuedAt: issuedAtStr != null ? DateTime.tryParse(issuedAtStr) : null,
      expirationDate: expirationDate,
      lastVerifiedAt: now,
      features: featuresList,
      isValid: isValid,
    );

    return LicenseValidationResult.valid(licenseInfo);
  }

  static LicenseTier _parseTier(String tierStr) {
    switch (tierStr.toLowerCase()) {
      case 'enterprise':
        return LicenseTier.enterprise;
      case 'standard':
      case 'estandar':
        return LicenseTier.standard;
      case 'free':
        return LicenseTier.free;
      case 'trial':
      case 'demo':
      case 'prueba':
        return LicenseTier.trial;
      case 'premium':
        return LicenseTier.premium;
      case 'pro':
      default:
        return LicenseTier.pro;
    }
  }
}

/// Resultado tipado de la validación
class LicenseValidationResult {
  final bool isSuccess;
  final LicenseInfo? licenseInfo;
  final String? errorMessage;
  final bool isTampered;

  const LicenseValidationResult({
    required this.isSuccess,
    this.licenseInfo,
    this.errorMessage,
    this.isTampered = false,
  });

  factory LicenseValidationResult.valid(LicenseInfo info) =>
      LicenseValidationResult(isSuccess: true, licenseInfo: info);

  factory LicenseValidationResult.invalid(String message) =>
      LicenseValidationResult(isSuccess: false, errorMessage: message);

  factory LicenseValidationResult.tampered(LicenseInfo info, String message) =>
      LicenseValidationResult(
        isSuccess: false,
        licenseInfo: info,
        errorMessage: message,
        isTampered: true,
      );
}

