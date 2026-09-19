import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/utils/tax_calculator.dart';

void main() {
  group('TaxCalculator - Liquidación de Impuestos Ecuador (15%)', () {
    test('Calcula correctamente ítems gravados con IVA 15%', () {
      final items = [
        const TaxableItem(unitPrice: 10.00, quantity: 2.0, isIvaExempt: false),
      ];

      final result = TaxCalculator.calculate(items, vatRate: 0.15);

      expect(result.subtotal15, equals(20.00));
      expect(result.subtotal0, equals(0.00));
      expect(result.iva15, equals(3.00)); // 20 * 0.15 = 3.00
      expect(result.grandTotal, equals(23.00));
    });

    test('Calcula correctamente medicamentos exentos con tarifa 0%', () {
      final items = [
        const TaxableItem(unitPrice: 5.50, quantity: 4.0, isIvaExempt: true),
      ];

      final result = TaxCalculator.calculate(items, vatRate: 0.15);

      expect(result.subtotal0, equals(22.00));
      expect(result.subtotal15, equals(0.00));
      expect(result.iva15, equals(0.00));
      expect(result.grandTotal, equals(22.00));
    });

    test('Calcula correctamente canastas mixtas con descuentos', () {
      final items = [
        // Medicamento exento: 1 unidad a $10 con $1 de descuento -> $9 neto (0%)
        const TaxableItem(unitPrice: 10.00, quantity: 1.0, discount: 1.00, isIvaExempt: true),
        // Producto gravado: 2 unidades a $10 -> $20 neto (15%)
        const TaxableItem(unitPrice: 10.00, quantity: 2.0, discount: 0.00, isIvaExempt: false),
      ];

      final result = TaxCalculator.calculate(items, vatRate: 0.15);

      expect(result.subtotal0, equals(9.00));
      expect(result.subtotal15, equals(20.00));
      expect(result.totalDiscount, equals(1.00));
      expect(result.iva15, equals(3.00)); // 20 * 0.15
      expect(result.grandTotal, equals(32.00)); // 9 + 20 + 3 = 32
    });

    test('Calcula correctamente con la tasa predeterminada de IVA 12%', () {
      final items = [
        const TaxableItem(unitPrice: 50.00, quantity: 1.0, isIvaExempt: false),
      ];

      // Utiliza la constante por defecto AppConstants.ivaVigente (0.12)
      final result = TaxCalculator.calculate(items);

      expect(result.subtotal12, equals(50.00));
      expect(result.iva12, equals(6.00)); // 50 * 0.12 = 6.00
      expect(result.grandTotal, equals(56.00));
    });
  });
}
