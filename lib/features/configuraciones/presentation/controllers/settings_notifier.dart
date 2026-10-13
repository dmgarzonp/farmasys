import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/settings_state.dart';
import '../../data/settings_repository.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late SettingsRepository _repo;
  bool _disposed = false;

  @override
  SettingsState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _repo = ref.read(settingsRepositoryProvider);
    _loadSettings();
    return const SettingsState();
  }

  Future<void> reloadSettings() async => _loadSettings();

  Future<void> _loadSettings() async {
    final iva = await _repo.getIva() ?? 0.15;
    final exp = await _repo.getExpirationDays() ?? 30;
    final stock = await _repo.getStockMinimo() ?? 5;

    final ruc = await _repo.getSriRuc() ?? '';
    final razonSocial = await _repo.getSriRazonSocial() ?? '';
    final estab = await _repo.getSriEstablecimiento() ?? '001';
    final punto = await _repo.getSriPuntoEmision() ?? '001';
    final amb = await _repo.getSriAmbiente() ?? 1;
    final fPath = await _repo.getSriFirmaPath() ?? '';
    final fPass = await _repo.getSriFirmaPassword() ?? '';

    final localBackup = await _repo.getAutoLocalBackup() ?? false;
    final cloudBackup = await _repo.getAutoCloudBackup() ?? false;
    final schedHour = await _repo.getScheduledBackupHour() ?? 23;
    final schedMinute = await _repo.getScheduledBackupMinute() ?? 50;
    final gdriveEmail = await _repo.getGoogleDriveEmail() ?? '';

    final pharmacyName = await _repo.getPharmacyName() ?? 'Mi Farmacia';
    final themeModeStr = await _repo.getThemeMode() ?? 'system';
    final primaryColorValue = await _repo.getPrimaryColor() ?? 0xFF059669;

    ThemeMode themeMode;
    switch (themeModeStr) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        themeMode = ThemeMode.system;
        break;
    }

    if (_disposed) return;

    state = SettingsState(
      ivaVigente: iva,
      expirationAlertDays: exp,
      stockMinimo: stock,
      sriRuc: ruc,
      sriRazonSocial: razonSocial,
      sriEstablecimiento: estab,
      sriPuntoEmision: punto,
      sriAmbiente: amb,
      sriFirmaPath: fPath,
      sriFirmaPassword: fPass,
      autoLocalBackupEnabled: localBackup,
      autoCloudBackupEnabled: cloudBackup,
      scheduledBackupHour: schedHour,
      scheduledBackupMinute: schedMinute,
      googleDriveEmail: gdriveEmail,
      pharmacyName: pharmacyName,
      themeMode: themeMode,
      primaryColor: Color(primaryColorValue),
    );
  }

  Future<void> updatePharmacyName(String name) async {
    final trimmed = name.trim();
    final valueToSave = trimmed.isEmpty ? 'Mi Farmacia' : trimmed;
    await _repo.savePharmacyName(valueToSave);
    state = state.copyWith(pharmacyName: valueToSave);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _repo.saveThemeMode(modeStr);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updatePrimaryColor(Color color) async {
    // ignore: deprecated_member_use
    await _repo.savePrimaryColor(color.value);
    state = state.copyWith(primaryColor: color);
  }

  Future<void> linkGoogleDrive(String email) async {
    await _repo.saveGoogleDriveEmail(email);
    await _repo.saveAutoCloudBackup(true);
    state = state.copyWith(
      googleDriveEmail: email,
      autoCloudBackupEnabled: true,
    );
  }

  Future<void> unlinkGoogleDrive() async {
    await _repo.clearGoogleDriveEmail();
    await _repo.saveAutoCloudBackup(false);
    state = state.copyWith(
      googleDriveEmail: '',
      autoCloudBackupEnabled: false,
    );
  }

  Future<void> updateScheduledBackupTime(int hour, int minute) async {
    await _repo.saveScheduledBackupTime(hour, minute);
    state = state.copyWith(
      scheduledBackupHour: hour,
      scheduledBackupMinute: minute,
    );
  }

  Future<void> toggleAutoLocalBackup(bool enabled) async {
    await _repo.saveAutoLocalBackup(enabled);
    state = state.copyWith(autoLocalBackupEnabled: enabled);
  }

  Future<void> toggleAutoCloudBackup(bool enabled) async {
    await _repo.saveAutoCloudBackup(enabled);
    state = state.copyWith(autoCloudBackupEnabled: enabled);
  }

  Future<void> updateIva(double newIva) async {
    await _repo.saveIva(newIva);
    state = state.copyWith(ivaVigente: newIva);
  }

  Future<void> updateExpirationDays(int days) async {
    await _repo.saveExpirationDays(days);
    state = state.copyWith(expirationAlertDays: days);
  }

  Future<void> updateStockMinimo(int stock) async {
    await _repo.saveStockMinimo(stock);
    state = state.copyWith(stockMinimo: stock);
  }

  Future<void> updateSriSettings({
    String? ruc,
    String? razonSocial,
    String? establecimiento,
    String? puntoEmision,
    int? ambiente,
    String? firmaPath,
    String? firmaPassword,
  }) async {
    await _repo.saveSriSettings(
      ruc: ruc,
      razonSocial: razonSocial,
      establecimiento: establecimiento,
      puntoEmision: puntoEmision,
      ambiente: ambiente,
      firmaPath: firmaPath,
      firmaPassword: firmaPassword,
    );
    state = state.copyWith(
      sriRuc: ruc,
      sriRazonSocial: razonSocial,
      sriEstablecimiento: establecimiento,
      sriPuntoEmision: puntoEmision,
      sriAmbiente: ambiente,
      sriFirmaPath: firmaPath,
      sriFirmaPassword: firmaPassword,
    );
  }
}
