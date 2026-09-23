import '../constants/app_constants.dart';

/// Representación inmutable de un ítem para cálculo tributario
class TaxableItem {
  final double unitPrice;
  final double quantity;
  final double discount; // Descuento monetario directo
  final bool isIvaExempt; // Medicamentos o insumos con tarifa 0%

  const TaxableItem({
    required this.unitPrice,
    required this.quantity,
    this.discount = 0.0,
    this.isIvaExempt = false,
  });

  double get grossSubtotal => unitPrice * quantity;
  double get netSubtotal => (grossSubtotal - discount).clamp(0.0, double.infinity);
}

/// Resultado consolidado de la liquidación de impuestos para factura o POS
class TaxCalculationResult {
  final double subtotal0; // Base imponible tarifa 0%
  final double subtotalIva; // Base imponible gravada con IVA (15%)
  final double totalDiscount; // Descuento global
  final double ivaAmount; // Monto de IVA liquidado
  final double grandTotal; // Total general a pagar

  // Getters de conveniencia y retrocompatibilidad
  double get subtotal12 => subtotalIva;
  double get subtotal15 => subtotalIva;
  double get iva12 => ivaAmount;
  double get iva15 => ivaAmount;

  const TaxCalculationResult({
    required this.subtotal0,
    required this.subtotalIva,
    required this.totalDiscount,
    required this.ivaAmount,
    required this.grandTotal,
  });
}

/// Motor de cálculo de impuestos conforme a la normativa tributaria ecuatoriana
class TaxCalculator {
  TaxCalculator._();

  static TaxCalculationResult calculate(List<TaxableItem> items, {required double vatRate}) {
    double subtotal0 = 0.0;
    double subtotalIva = 0.0;
    double totalDiscount = 0.0;

    for (final item in items) {
      totalDiscount += item.discount;
      final double itemNet = item.netSubtotal;

      if (item.isIvaExempt) {
        subtotal0 += itemNet;
      } else {
        subtotalIva += itemNet;
      }
    }

    final double ivaAmount = _round2(subtotalIva * vatRate);
    final double grandTotal = _round2(subtotal0 + subtotalIva + ivaAmount);

    return TaxCalculationResult(
      subtotal0: _round2(subtotal0),
      subtotalIva: _round2(subtotalIva),
      totalDiscount: _round2(totalDiscount),
      ivaAmount: ivaAmount,
      grandTotal: grandTotal,
    );
  }

  static double _round2(double val) {
    return (val * 100).roundToDouble() / 100;
  }
}
