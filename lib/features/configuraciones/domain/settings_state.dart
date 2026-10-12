class SettingsState {
  final double ivaVigente;
  final int expirationAlertDays;
  final int stockMinimo;
  
  // SRI Settings
  final String sriRuc;
  final String sriRazonSocial;
  final String sriEstablecimiento;
  final String sriPuntoEmision;
  final int sriAmbiente; // 1 = Pruebas, 2 = Producción
  final String sriFirmaPath;
  final String sriFirmaPassword;

  // Backup Settings
  final bool autoLocalBackupEnabled;
  final bool autoCloudBackupEnabled;
  final int scheduledBackupHour;
  final int scheduledBackupMinute;
  final String googleDriveEmail;

  const SettingsState({
    this.ivaVigente = 0.15,
    this.expirationAlertDays = 30,
    this.stockMinimo = 5,
    this.sriRuc = '',
    this.sriRazonSocial = '',
    this.sriEstablecimiento = '001',
    this.sriPuntoEmision = '001',
    this.sriAmbiente = 1,
    this.sriFirmaPath = '',
    this.sriFirmaPassword = '',
    this.autoLocalBackupEnabled = false,
    this.autoCloudBackupEnabled = false,
    this.scheduledBackupHour = 23,
    this.scheduledBackupMinute = 50,
    this.googleDriveEmail = '',
  });

  SettingsState copyWith({
    double? ivaVigente,
    int? expirationAlertDays,
    int? stockMinimo,
    String? sriRuc,
    String? sriRazonSocial,
    String? sriEstablecimiento,
    String? sriPuntoEmision,
    int? sriAmbiente,
    String? sriFirmaPath,
    String? sriFirmaPassword,
    bool? autoLocalBackupEnabled,
    bool? autoCloudBackupEnabled,
    int? scheduledBackupHour,
    int? scheduledBackupMinute,
    String? googleDriveEmail,
  }) {
    return SettingsState(
      ivaVigente: ivaVigente ?? this.ivaVigente,
      expirationAlertDays: expirationAlertDays ?? this.expirationAlertDays,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      sriRuc: sriRuc ?? this.sriRuc,
      sriRazonSocial: sriRazonSocial ?? this.sriRazonSocial,
      sriEstablecimiento: sriEstablecimiento ?? this.sriEstablecimiento,
      sriPuntoEmision: sriPuntoEmision ?? this.sriPuntoEmision,
      sriAmbiente: sriAmbiente ?? this.sriAmbiente,
      sriFirmaPath: sriFirmaPath ?? this.sriFirmaPath,
      sriFirmaPassword: sriFirmaPassword ?? this.sriFirmaPassword,
      autoLocalBackupEnabled: autoLocalBackupEnabled ?? this.autoLocalBackupEnabled,
      autoCloudBackupEnabled: autoCloudBackupEnabled ?? this.autoCloudBackupEnabled,
      scheduledBackupHour: scheduledBackupHour ?? this.scheduledBackupHour,
      scheduledBackupMinute: scheduledBackupMinute ?? this.scheduledBackupMinute,
      googleDriveEmail: googleDriveEmail ?? this.googleDriveEmail,
    );
  }
}
