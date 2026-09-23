import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsRepository {
  static const _keyIva = 'settings_iva_vigente';
  static const _keyExpiration = 'settings_expiration_days';
  static const _keyStock = 'settings_stock_minimo';

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
}
