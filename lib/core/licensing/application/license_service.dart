import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/license_info.dart';

part 'license_service.g.dart';

@Riverpod(keepAlive: true)
class LicenseService extends _$LicenseService {
  @override
  FutureOr<LicenseInfo> build() async {
    // Leemos el estado local de la licencia
    return _checkLocalLicense();
  }

  Future<LicenseInfo> _checkLocalLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium_license') ?? false;

    if (isPremium) {
      return const LicenseInfo(
        tier: LicenseTier.premium,
        isValid: true,
      );
    }
    
    return LicenseInfo.free();
  }

  Future<void> activatePremiumLicense(String licenseKey) async {
    state = const AsyncLoading();
    
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simular latencia de red
      
      // Validación básica (en producción iría contra un servidor con criptografía asimétrica)
      if (licenseKey.trim().toUpperCase() == 'PREMIUM-FARMSYS') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_premium_license', true);
        
        state = const AsyncData(LicenseInfo(
          tier: LicenseTier.premium,
          isValid: true,
        ));
      } else {
        throw Exception('La clave de licencia proporcionada no es válida.');
      }
    } catch (e, st) {
      state = AsyncData(await _checkLocalLicense());
      throw Exception(e.toString());
    }
  }

  Future<void> deactivateLicense() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_premium_license');
    state = AsyncData(LicenseInfo.free());
  }
}
