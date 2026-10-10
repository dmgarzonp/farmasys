import 'package:equatable/equatable.dart';

enum LicenseTier {
  free,
  premium,
}

class LicenseInfo extends Equatable {
  final LicenseTier tier;
  final DateTime? expirationDate;
  final String? hardwareId;
  final String? assignedTo;
  final bool isValid;

  const LicenseInfo({
    required this.tier,
    this.expirationDate,
    this.hardwareId,
    this.assignedTo,
    required this.isValid,
  });

  bool get isPremium => tier == LicenseTier.premium && isValid;

  factory LicenseInfo.free() {
    return const LicenseInfo(
      tier: LicenseTier.free,
      isValid: true,
    );
  }

  @override
  List<Object?> get props => [tier, expirationDate, hardwareId, assignedTo, isValid];
}
