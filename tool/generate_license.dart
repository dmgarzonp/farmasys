import 'dart:io';
import '../lib/core/licensing/data/license_crypto_service.dart';
import '../lib/core/licensing/domain/license_info.dart';

/// Herramienta administrativa para generar y firmar licencias comerciales de FarmSys.
/// 
/// Uso CLI:
///   dart run tool/generate_license.dart --ruc 1792345678001 --name "Farmacia San Carlos" --machine "FARM-MCH-XXXX-XXXX-XXXX" --days 365 --plan pro
/// 
/// Modo Interactivo:
///   dart run tool/generate_license.dart
void main(List<String> args) {
  print('================================================================');
  print('       FARMSYS ECUADOR - GENERADOR OFICIAL DE LICENCIAS        ');
  print('================================================================\n');

  Map<String, String> params = {};
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--trial' || arg == '--demo') {
      params['trial'] = 'true';
    } else if (arg.startsWith('--') && i + 1 < args.length && !args[i + 1].startsWith('--')) {
      params[arg.substring(2)] = args[i + 1];
      i++;
    }
  }

  final isTrialArg = args.contains('--trial') || args.contains('--demo');

  String ruc = params['ruc'] ?? '';
  String name = params['name'] ?? '';
  String machine = params['machine'] ?? '';
  String daysStr = params['days'] ?? (isTrialArg ? '30' : '365');
  String planStr = params['plan'] ?? (isTrialArg ? 'trial' : 'pro');

  // Modo interactivo si faltan argumentos
  if (ruc.isEmpty) {
    stdout.write('1. Ingrese el RUC de la Farmacia (13 dígitos): ');
    ruc = stdin.readLineSync()?.trim() ?? '';
  }
  if (name.isEmpty) {
    stdout.write('2. Ingrese la Razón Social / Nombre Comercial: ');
    name = stdin.readLineSync()?.trim() ?? 'Farmacia Cliente';
  }
  if (machine.isEmpty) {
    stdout.write('3. Ingrese el Machine ID del equipo cliente (ej. FARM-MCH-XXXX... o * para universal): ');
    machine = stdin.readLineSync()?.trim() ?? '*';
  }
  if (params['days'] == null && !isTrialArg) {
    print('\n4. Seleccione el Tipo y Tiempo de Licencia:');
    print('   [1] Demo / Prueba de 30 días (Trial con SRI desbloqueado)');
    print('   [2] Suscripción Mensual (30 días)');
    print('   [3] Suscripción Anual (365 días) - [Recomendado]');
    print('   [4] Tiempo Personalizado');
    stdout.write('   Selección [3]: ');
    final sel = stdin.readLineSync()?.trim() ?? '3';

    if (sel == '1') {
      daysStr = '30';
      planStr = 'trial';
    } else if (sel == '2') {
      daysStr = '30';
      planStr = 'pro';
    } else if (sel == '4') {
      stdout.write('   Ingrese número de días: ');
      daysStr = stdin.readLineSync()?.trim() ?? '30';
      stdout.write('   Ingrese plan (standard / pro / enterprise): ');
      planStr = stdin.readLineSync()?.trim() ?? 'pro';
    } else {
      daysStr = '365';
      planStr = 'pro';
    }
  }

  if (ruc.isEmpty) {
    print('\n[ERROR] El RUC es obligatorio para expedir la licencia.');
    exit(1);
  }

  final days = int.tryParse(daysStr) ?? 365;
  final now = DateTime.now();
  final validUntil = now.add(Duration(days: days));

  LicenseTier tier;
  switch (planStr.toLowerCase()) {
    case 'trial':
    case 'demo':
    case 'prueba':
      tier = LicenseTier.trial;
      break;
    case 'enterprise':
      tier = LicenseTier.enterprise;
      break;
    case 'standard':
      tier = LicenseTier.standard;
      break;
    case 'pro':
    default:
      tier = LicenseTier.pro;
      break;
  }

  // Generar el token criptográfico firmado
  final token = LicenseCryptoService.generateSignedToken(
    ruc: ruc,
    businessName: name,
    machineId: machine.isEmpty ? '*' : machine,
    validUntil: validUntil,
    tier: tier,
    issuedAt: now,
  );

  // Validación de seguridad previa
  final check = LicenseCryptoService.validateToken(
    rawToken: token,
    currentMachineId: machine.isEmpty ? '*' : machine,
  );

  if (!check.isSuccess) {
    print('\n[ERROR CRÍTICO] La prueba de firma falló: ${check.errorMessage}');
    exit(1);
  }

  print('\n------------------- RESUMEN DE LA LICENCIA --------------------');
  print('  Razón Social  : $name');
  print('  RUC           : $ruc');
  print('  Machine ID    : ${machine.isEmpty ? '*' : machine}');
  print('  Plan          : ${tier.name.toUpperCase()}');
  print('  Fecha Emisión : ${now.toString().split(' ')[0]}');
  print('  Fecha Vence   : ${validUntil.toString().split(' ')[0]} ($days días)');
  print('  Periodo Gracia: +${LicenseCryptoService.gracePeriodDays} días post-vencimiento');
  print('----------------------------------------------------------------');
  print('\n>>> COPIA EL SIGUIENTE TOKEN Y ENVÍALO AL CLIENTE:\n');
  print(token);
  print('\n----------------------------------------------------------------');
  print('Instrucciones para el cliente:');
  print('1. Abrir FarmSys -> Configuración -> Activar Licencia.');
  print('2. Pegar este token y hacer clic en "Activar".');
  print('================================================================\n');
}

