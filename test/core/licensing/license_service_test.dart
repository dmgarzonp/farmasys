import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/licensing/data/license_crypto_service.dart';
import 'package:farmsys/core/licensing/domain/license_info.dart';

void main() {
  const testMachineId = 'FARM-MCH-9B4F-8A2C-1E30';
  const testRuc = '1792345678001';
  const testName = 'Farmacia San Carlos';

  group('Pruebas del Motor de Licenciamiento Criptográfico (FarmSys)', () {
    test('Genera y valida exitosamente un token para la máquina correcta', () {
      final validUntil = DateTime.now().add(const Duration(days: 365));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: testMachineId,
        validUntil: validUntil,
        tier: LicenseTier.pro,
      );

      final result = LicenseCryptoService.validateToken(
        rawToken: token,
        currentMachineId: testMachineId,
      );

      expect(result.isSuccess, isTrue);
      expect(result.licenseInfo, isNotNull);
      expect(result.licenseInfo!.status, LicenseStatus.active);
      expect(result.licenseInfo!.isValid, isTrue);
      expect(result.licenseInfo!.canSell, isTrue);
      expect(result.licenseInfo!.isPremium, isTrue);
      expect(result.licenseInfo!.ruc, testRuc);
      expect(result.licenseInfo!.businessName, testName);
      expect(result.licenseInfo!.tier, LicenseTier.pro);
      expect(result.licenseInfo!.daysRemaining, greaterThanOrEqualTo(364));
    });

    test('Rechaza token si la firma ha sido alterada o falsificada', () {
      final validUntil = DateTime.now().add(const Duration(days: 365));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: testMachineId,
        validUntil: validUntil,
      );

      // Alteramos un carácter de la firma
      final tamperedToken = '${token.substring(0, token.length - 4)}AAAA';
      final result = LicenseCryptoService.validateToken(
        rawToken: tamperedToken,
        currentMachineId: testMachineId,
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('firma digital'));
    });

    test('Rechaza token si el Machine ID no coincide (protección anti-piratería)', () {
      final validUntil = DateTime.now().add(const Duration(days: 365));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: testMachineId,
        validUntil: validUntil,
      );

      const otherMachineId = 'FARM-MCH-0000-1111-2222';
      final result = LicenseCryptoService.validateToken(
        rawToken: token,
        currentMachineId: otherMachineId,
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('vinculada a otro equipo'));
    });

    test('Acepta token wildcard (*) en cualquier máquina', () {
      final validUntil = DateTime.now().add(const Duration(days: 365));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: '*',
        validUntil: validUntil,
      );

      const anyMachineId = 'FARM-MCH-9999-8888-7777';
      final result = LicenseCryptoService.validateToken(
        rawToken: token,
        currentMachineId: anyMachineId,
      );

      expect(result.isSuccess, isTrue);
      expect(result.licenseInfo!.canSell, isTrue);
    });

    test('Reconoce periodo de gracia (Grace Period) si venció hace menos de 15 días', () {
      // Venció hace 5 días
      final validUntil = DateTime.now().subtract(const Duration(days: 5));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: testMachineId,
        validUntil: validUntil,
      );

      final result = LicenseCryptoService.validateToken(
        rawToken: token,
        currentMachineId: testMachineId,
      );

      expect(result.isSuccess, isTrue);
      expect(result.licenseInfo!.status, LicenseStatus.gracePeriod);
      expect(result.licenseInfo!.inGracePeriod, isTrue);
      expect(result.licenseInfo!.canSell, isTrue); // Permite vender en gracia
      expect(result.licenseInfo!.daysRemaining, isNegative);
    });

    test('Marca como expirada si venció hace más de 15 días (fuera de gracia)', () {
      // Venció hace 20 días
      final validUntil = DateTime.now().subtract(const Duration(days: 20));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: testMachineId,
        validUntil: validUntil,
      );

      final result = LicenseCryptoService.validateToken(
        rawToken: token,
        currentMachineId: testMachineId,
      );

      expect(result.isSuccess, isTrue);
      expect(result.licenseInfo!.status, LicenseStatus.expired);
      expect(result.licenseInfo!.isExpired, isTrue);
      expect(result.licenseInfo!.canSell, isFalse); // Bloquea ventas
    });

    test('Detecta alteración intencional del reloj del sistema (Clock Rollback)', () {
      final validUntil = DateTime.now().add(const Duration(days: 365));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: testMachineId,
        validUntil: validUntil,
      );

      // Simulamos que el sistema ya había registrado uso mañana
      final futureWatermark = DateTime.now().add(const Duration(days: 2));

      final result = LicenseCryptoService.validateToken(
        rawToken: token,
        currentMachineId: testMachineId,
        lastSeenClock: futureWatermark,
      );

      expect(result.isSuccess, isFalse);
      expect(result.isTampered, isTrue);
      expect(result.licenseInfo!.status, LicenseStatus.tamperedClock);
      expect(result.licenseInfo!.canSell, isFalse);
    });

    test('Genera y valida correctamente una licencia temporal de prueba (Trial 30 días)', () {
      final validUntil = DateTime.now().add(const Duration(days: 30));
      final token = LicenseCryptoService.generateSignedToken(
        ruc: testRuc,
        businessName: testName,
        machineId: testMachineId,
        validUntil: validUntil,
        tier: LicenseTier.trial,
      );

      final result = LicenseCryptoService.validateToken(
        rawToken: token,
        currentMachineId: testMachineId,
      );

      expect(result.isSuccess, isTrue);
      expect(result.licenseInfo!.tier, LicenseTier.trial);
      expect(result.licenseInfo!.isTrial, isTrue);
      expect(result.licenseInfo!.isPremium, isTrue); // Permite probar SRI
      expect(result.licenseInfo!.canSell, isTrue); // Permite vender
      expect(result.licenseInfo!.daysRemaining, inInclusiveRange(29, 30));
    });
  });
}

