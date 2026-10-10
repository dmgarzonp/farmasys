import 'package:intl/intl.dart';

class SriAccessKeyGenerator {
  /// Genera la clave de acceso de 49 dígitos para el SRI.
  /// [date] Fecha de emisión.
  /// [documentType] Tipo de comprobante (Ej: '01' para Factura).
  /// [ruc] RUC del emisor (13 dígitos).
  /// [environment] Ambiente (1 = Pruebas, 2 = Producción).
  /// [establishment] Establecimiento (3 dígitos, ej: '001').
  /// [emissionPoint] Punto de emisión (3 dígitos, ej: '001').
  /// [sequential] Secuencial del comprobante (9 dígitos, ej: '000000123').
  /// [numericCode] Código numérico de 8 dígitos (puede ser un correlativo interno, ej: '12345678').
  static String generate({
    required DateTime date,
    required String documentType,
    required String ruc,
    required int environment,
    required String establishment,
    required String emissionPoint,
    required String sequential,
    required String numericCode,
  }) {
    final dateStr = DateFormat('ddMMyyyy').format(date);
    final envStr = environment.toString();
    final emissionType = '1'; // 1 = Emisión Normal

    // Validar longitudes
    final safeRuc = ruc.padLeft(13, '0').substring(0, 13);
    final safeEstab = establishment.padLeft(3, '0').substring(0, 3);
    final safePtoEmi = emissionPoint.padLeft(3, '0').substring(0, 3);
    final safeSeq = sequential.padLeft(9, '0').substring(0, 9);
    final safeNumCode = numericCode.padLeft(8, '0').substring(0, 8);

    final baseKey = '$dateStr'
        '$documentType'
        '$safeRuc'
        '$envStr'
        '$safeEstab$safePtoEmi'
        '$safeSeq'
        '$safeNumCode'
        '$emissionType';

    final checkDigit = _calculateModulo11(baseKey);

    return '$baseKey$checkDigit';
  }

  /// Calcula el dígito verificador usando el algoritmo Módulo 11 (SRI)
  static int _calculateModulo11(String baseKey) {
    int pivot = 2;
    int sum = 0;

    // Iteramos de derecha a izquierda
    for (int i = baseKey.length - 1; i >= 0; i--) {
      final digit = int.parse(baseKey[i]);
      sum += digit * pivot;
      
      pivot++;
      if (pivot > 7) {
        pivot = 2;
      }
    }

    int checkDigit = 11 - (sum % 11);

    if (checkDigit == 11) {
      checkDigit = 0;
    } else if (checkDigit == 10) {
      checkDigit = 1;
    }

    return checkDigit;
  }
}
