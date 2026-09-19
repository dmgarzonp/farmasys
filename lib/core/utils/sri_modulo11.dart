/// Utilidad para la generación y validación de la Clave de Acceso del SRI
/// utilizando el algoritmo ponderado Módulo 11 (Ecuador).
class SriModulo11 {
  SriModulo11._();

  /// Calcula el dígito verificador para una cadena numérica de 48 dígitos.
  /// Ponderación cíclica: 7, 6, 5, 4, 3, 2 de derecha a izquierda.
  static int calcularDigitoVerificador(String cadena48) {
    if (cadena48.length != 48 || !RegExp(r'^\d+$').hasMatch(cadena48)) {
      throw ArgumentError('La cadena para calcular el dígito debe tener exactamente 48 dígitos numéricos.');
    }

    int factor = 2;
    int suma = 0;

    for (int i = cadena48.length - 1; i >= 0; i--) {
      final int digito = int.parse(cadena48[i]);
      suma += digito * factor;
      factor = factor == 7 ? 2 : factor + 1;
    }

    final int residuo = suma % 11;
    final int resultado = 11 - residuo;

    if (resultado == 11) {
      return 0;
    } else if (resultado == 10) {
      return 1;
    } else {
      return resultado;
    }
  }

  /// Construye la clave de acceso completa de 49 dígitos para comprobantes electrónicos.
  static String generarClaveAcceso({
    required DateTime fechaEmision,
    required String tipoComprobante, // 2 dígitos (ej: '01' factura)
    required String ruc, // 13 dígitos
    required String ambiente, // '1' pruebas, '2' producción
    required String establecimiento, // 3 dígitos (ej: '001')
    required String puntoEmision, // 3 dígitos (ej: '001')
    required String secuencial, // 9 dígitos (ej: '000000001')
    required String codigoNumerico, // 8 dígitos aleatorios/fijos
    String tipoEmision = '1', // '1' normal
  }) {
    final String dia = fechaEmision.day.toString().padLeft(2, '0');
    final String mes = fechaEmision.month.toString().padLeft(2, '0');
    final String anio = fechaEmision.year.toString();
    final String fechaFormato = '$dia$mes$anio';

    final String serie = '${establecimiento.padLeft(3, '0')}${puntoEmision.padLeft(3, '0')}';
    final String sec = secuencial.padLeft(9, '0');
    final String codNum = codigoNumerico.padLeft(8, '0');

    final String base48 = '$fechaFormato'
        '${tipoComprobante.padLeft(2, '0')}'
        '${ruc.padLeft(13, '0')}'
        '$ambiente'
        '$serie'
        '$sec'
        '$codNum'
        '$tipoEmision';

    final int digitoVerificador = calcularDigitoVerificador(base48);
    return '$base48$digitoVerificador';
  }

  /// Valida si una clave de acceso de 49 dígitos es matemáticamente válida.
  static bool validarClaveAcceso(String clave49) {
    if (clave49.length != 49 || !RegExp(r'^\d+$').hasMatch(clave49)) {
      return false;
    }

    final String base48 = clave49.substring(0, 48);
    final int digitoEsperado = int.parse(clave49[48]);
    final int digitoCalculado = calcularDigitoVerificador(base48);

    return digitoEsperado == digitoCalculado;
  }
}
