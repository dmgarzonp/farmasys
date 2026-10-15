import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

  // Backup Keys
  static const _keyAutoLocalBackup = 'settings_auto_local_backup';
  static const _keyAutoCloudBackup = 'settings_auto_cloud_backup';
  static const _keyScheduledBackupHour = 'settings_scheduled_backup_hour';
  static const _keyScheduledBackupMinute = 'settings_scheduled_backup_minute';
  static const _keyGoogleDriveEmail = 'settings_google_drive_email';

  // Personalización Keys
  static const _keyPharmacyName = 'settings_pharmacy_name';
  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyPrimaryColor = 'settings_primary_color';

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

  // Backup Getters
  Future<bool?> getAutoLocalBackup() async => (await SharedPreferences.getInstance()).getBool(_keyAutoLocalBackup);
  Future<bool?> getAutoCloudBackup() async => (await SharedPreferences.getInstance()).getBool(_keyAutoCloudBackup);
  Future<int?> getScheduledBackupHour() async => (await SharedPreferences.getInstance()).getInt(_keyScheduledBackupHour);
  Future<int?> getScheduledBackupMinute() async => (await SharedPreferences.getInstance()).getInt(_keyScheduledBackupMinute);
  Future<String?> getGoogleDriveEmail() async => (await SharedPreferences.getInstance()).getString(_keyGoogleDriveEmail);

  // Backup Setters
  Future<void> saveAutoLocalBackup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLocalBackup, enabled);
  }

  Future<void> saveAutoCloudBackup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoCloudBackup, enabled);
  }

  Future<void> saveScheduledBackupTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScheduledBackupHour, hour);
    await prefs.setInt(_keyScheduledBackupMinute, minute);
  }

  Future<void> saveGoogleDriveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGoogleDriveEmail, email);
  }

  Future<void> clearGoogleDriveEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGoogleDriveEmail);
  }

  // Personalización Getters
  Future<String?> getPharmacyName() async => (await SharedPreferences.getInstance()).getString(_keyPharmacyName);
  Future<String?> getThemeMode() async => (await SharedPreferences.getInstance()).getString(_keyThemeMode);
  Future<int?> getPrimaryColor() async => (await SharedPreferences.getInstance()).getInt(_keyPrimaryColor);

  // Personalización Setters
  Future<void> savePharmacyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPharmacyName, name);
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<void> savePrimaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrimaryColor, colorValue);
  }

  // SRI Getters
  Future<String?> getSriRuc() async => (await SharedPreferences.getInstance()).getString(_keySriRuc);
  Future<String?> getSriRazonSocial() async => (await SharedPreferences.getInstance()).getString(_keySriRazonSocial);
  Future<String?> getSriEstablecimiento() async => (await SharedPreferences.getInstance()).getString(_keySriEstablecimiento);
  Future<String?> getSriPuntoEmision() async => (await SharedPreferences.getInstance()).getString(_keySriPuntoEmision);
  Future<int?> getSriAmbiente() async => (await SharedPreferences.getInstance()).getInt(_keySriAmbiente);
  Future<String?> getSriFirmaPath() async => (await SharedPreferences.getInstance()).getString(_keySriFirmaPath);
  static const String _encPrefix = 'fs_sec_v1:';
  static const List<int> _cryptoSalt = [0x46, 0x53, 0x59, 0x53, 0x5F, 0x53, 0x52, 0x49]; // "FSYS_SRI"

  static String _protectSecret(String raw) {
    if (raw.isEmpty) return raw;
    final bytes = utf8.encode(raw);
    final obfuscated = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ _cryptoSalt[i % _cryptoSalt.length],
    );
    return '$_encPrefix${base64.encode(obfuscated)}';
  }

  static String _unprotectSecret(String stored) {
    if (!stored.startsWith(_encPrefix)) {
      // Compatibilidad con contraseñas que hayan sido guardadas previamente en texto plano
      return stored;
    }
    try {
      final base64Part = stored.substring(_encPrefix.length);
      final obfuscated = base64.decode(base64Part);
      final bytes = List<int>.generate(
        obfuscated.length,
        (i) => obfuscated[i] ^ _cryptoSalt[i % _cryptoSalt.length],
      );
      return utf8.decode(bytes);
    } catch (_) {
      return stored;
    }
  }

  Future<String?> getSriFirmaPassword() async {
    final raw = (await SharedPreferences.getInstance()).getString(_keySriFirmaPassword);
    if (raw == null) return null;
    return _unprotectSecret(raw);
  }

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
    if (firmaPassword != null) {
      await prefs.setString(_keySriFirmaPassword, _protectSecret(firmaPassword));
    }
  }

  // Database Path Management
  static const _keyCustomDbPath = 'settings_custom_db_path';

  Future<String?> getCustomDbPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomDbPath);
  }

  Future<void> saveCustomDbPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.trim().isEmpty) {
      await prefs.remove(_keyCustomDbPath);
    } else {
      await prefs.setString(_keyCustomDbPath, path.trim());
    }
  }

  Future<String> getDefaultDbPath() async {
    final defaultDir = await getApplicationDocumentsDirectory();
    return p.join(defaultDir.path, 'farmsys.db');
  }

  Future<String> getEffectiveDbPath() async {
    final custom = await getCustomDbPath();
    if (custom != null && custom.trim().isNotEmpty) {
      return custom.trim();
    }
    return getDefaultDbPath();
  }
}
