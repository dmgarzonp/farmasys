import 'package:intl/intl.dart';

/// Formateadores compartidos para moneda, fechas y claves tributarias
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: r'$ ',
    decimalDigits: 2,
    locale: 'en_US',
  );

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formatea un número decimal como moneda ($ 0.00)
  static String currency(double? amount) {
    if (amount == null) return r'$ 0.00';
    return _currencyFormat.format(amount);
  }

  /// Formatea una fecha como dd/MM/yyyy
  static String date(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateFormat.format(dateTime);
  }

  /// Formatea una fecha con hora como dd/MM/yyyy HH:mm
  static String dateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateTimeFormat.format(dateTime);
  }

  /// Retorna un texto descriptivo del tiempo restante de vencimiento de un lote
  static String relativeExpiration(DateTime expirationDate, [DateTime? referenceDate]) {
    final DateTime now = referenceDate ?? DateTime.now();
    final DateTime exp = DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int diffDays = exp.difference(today).inDays;

    if (diffDays < 0) {
      return 'Vencido hace ${diffDays.abs()} día(s)';
    } else if (diffDays == 0) {
      return 'Vence hoy';
    } else if (diffDays == 1) {
      return 'Vence mañana';
    } else if (diffDays <= 30) {
      return 'Próximo a vencer (${diffDays}d)';
    } else {
      return 'Vigente (${diffDays}d)';
    }
  }

  /// Formatea el número de factura legal de 9 dígitos con ceros a la izquierda
  /// Ej: 1 -> 000000001
  static String formatSecuencial(int id) {
    return id.toString().padLeft(9, '0');
  }

  /// Formatea el número completo de comprobante SRI: 001-001-000000001
  static String formatFullInvoiceNumber(String estab, String ptoEmi, int secuencial) {
    return '${estab.padLeft(3, '0')}-${ptoEmi.padLeft(3, '0')}-${formatSecuencial(secuencial)}';
  }
}
