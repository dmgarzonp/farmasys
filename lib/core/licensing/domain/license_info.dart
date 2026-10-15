import 'package:equatable/equatable.dart';

enum LicenseTier {
  free,
  standard,
  premium, // Retrocompatibilidad con settings_screen
  pro,
  enterprise,
  trial, // Periodo de prueba / demo temporal (ej. 30 días)
}

enum LicenseStatus {
  active,
  gracePeriod,
  expired,
  unlicensed,
  tamperedClock,
}

/// Entidad de dominio que representa el estado legal y técnico de la licencia de FarmSys.
class LicenseInfo extends Equatable {
  final LicenseTier tier;
  final LicenseStatus status;
  final String? licenseKey;
  final String? ruc;
  final String? businessName;
  final String? machineId;
  final DateTime? issuedAt;
  final DateTime? expirationDate;
  final DateTime? lastVerifiedAt;
  final List<String> features;
  final bool isValid;

  const LicenseInfo({
    required this.tier,
    required this.status,
    this.licenseKey,
    this.ruc,
    this.businessName,
    this.machineId,
    this.issuedAt,
    this.expirationDate,
    this.lastVerifiedAt,
    this.features = const [],
    required this.isValid,
  });

  /// Indica si la licencia es una versión de prueba / demo temporal
  bool get isTrial => tier == LicenseTier.trial;

  /// Retrocompatibilidad: Módulo SRI desbloqueado en planes premium, pro, enterprise y trial
  bool get isPremium =>
      (tier == LicenseTier.premium ||
          tier == LicenseTier.pro ||
          tier == LicenseTier.enterprise ||
          tier == LicenseTier.trial) &&
      isValid;

  /// Indica si la farmacia está autorizada para registrar ventas (activa o en periodo de gracia)
  bool get canSell =>
      isValid &&
      (status == LicenseStatus.active || status == LicenseStatus.gracePeriod);

  /// Indica si el sistema está dentro del periodo de tolerancia post-vencimiento (7 a 15 días)
  bool get inGracePeriod => status == LicenseStatus.gracePeriod;

  /// Indica si la licencia caducó completamente o el equipo no está licenciado
  bool get isExpired =>
      status == LicenseStatus.expired ||
      status == LicenseStatus.unlicensed ||
      status == LicenseStatus.tamperedClock;

  /// Días restantes hasta la fecha oficial de caducidad
  int get daysRemaining {
    if (expirationDate == null) return 0;
    final diff = expirationDate!.difference(DateTime.now()).inDays;
    return diff;
  }

  /// Verifica si una funcionalidad específica está autorizada en la licencia
  bool hasFeature(String feature) {
    if (!isValid) return false;
    if (features.isEmpty || features.contains('*')) return true;
    return features.contains(feature.toLowerCase());
  }

  factory LicenseInfo.unlicensed({String? machineId}) {
    return LicenseInfo(
      tier: LicenseTier.free,
      status: LicenseStatus.unlicensed,
      machineId: machineId,
      isValid: false,
    );
  }

  factory LicenseInfo.free({String? machineId}) {
    return LicenseInfo(
      tier: LicenseTier.free,
      status: LicenseStatus.active,
      machineId: machineId,
      isValid: true,
      features: const ['pos', 'inventory'],
    );
  }

  @override
  List<Object?> get props => [
        tier,
        status,
        licenseKey,
        ruc,
        businessName,
        machineId,
        issuedAt,
        expirationDate,
        lastVerifiedAt,
        features,
        isValid,
      ];
}
