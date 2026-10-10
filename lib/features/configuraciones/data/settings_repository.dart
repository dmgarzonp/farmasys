import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsRepository {
  static const _keyIva = 'settings_iva_vigente';
  static const _keyExpiration = 'settings_expiration_days';
  static const _keyStock = 'settings_stock_minimo';
  
  // SRI Keys
  static const _keySriRuc = 'settings_sri_ruc';
  static const _keySriRazonSocial = 'settings_sri_razon_social';
  static const _keySriEstablecimiento = 'settings_sri_establecimiento';
  static const _keySriPuntoEmision = 'settings_sri_punto_emision';
  static const _keySriAmbiente = 'settings_sri_ambiente';
  static const _keySriFirmaPath = 'settings_sri_firma_path';
  static const _keySriFirmaPassword = 'settings_sri_firma_password';

  Future<void> saveIva(double iva) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyIva, iva);
  }

  Future<double?> getIva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyIva);
  }

  Future<void> saveExpirationDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyExpiration, days);
  }

  Future<int?> getExpirationDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyExpiration);
  }

  Future<void> saveStockMinimo(int stock) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStock, stock);
  }

  Future<int?> getStockMinimo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStock);
  }

  // SRI Getters
  Future<String?> getSriRuc() async => (await SharedPreferences.getInstance()).getString(_keySriRuc);
  Future<String?> getSriRazonSocial() async => (await SharedPreferences.getInstance()).getString(_keySriRazonSocial);
  Future<String?> getSriEstablecimiento() async => (await SharedPreferences.getInstance()).getString(_keySriEstablecimiento);
  Future<String?> getSriPuntoEmision() async => (await SharedPreferences.getInstance()).getString(_keySriPuntoEmision);
  Future<int?> getSriAmbiente() async => (await SharedPreferences.getInstance()).getInt(_keySriAmbiente);
  Future<String?> getSriFirmaPath() async => (await SharedPreferences.getInstance()).getString(_keySriFirmaPath);
  Future<String?> getSriFirmaPassword() async => (await SharedPreferences.getInstance()).getString(_keySriFirmaPassword);

  // SRI Setters
  Future<void> saveSriSettings({
    String? ruc,
    String? razonSocial,
    String? establecimiento,
    String? puntoEmision,
    int? ambiente,
    String? firmaPath,
    String? firmaPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (ruc != null) await prefs.setString(_keySriRuc, ruc);
    if (razonSocial != null) await prefs.setString(_keySriRazonSocial, razonSocial);
    if (establecimiento != null) await prefs.setString(_keySriEstablecimiento, establecimiento);
    if (puntoEmision != null) await prefs.setString(_keySriPuntoEmision, puntoEmision);
    if (ambiente != null) await prefs.setInt(_keySriAmbiente, ambiente);
    if (firmaPath != null) await prefs.setString(_keySriFirmaPath, firmaPath);
    if (firmaPassword != null) await prefs.setString(_keySriFirmaPassword, firmaPassword);
  }
}
