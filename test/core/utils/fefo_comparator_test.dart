import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/utils/fefo_comparator.dart';

void main() {
  group('FefoComparator - Asignación FEFO de Inventario Farmacéutico', () {
    final DateTime refDate = DateTime(2026, 6, 1);

    final lot1 = LotItem(
      id: 1,
      lotNumber: 'LOT-A',
      expirationDate: DateTime(2026, 8, 1), // Vence en agosto
      entryDate: DateTime(2026, 1, 10),
      currentStock: 10.0,
      unitCost: 1.50,
    );

    final lot2 = LotItem(
      id: 2,
      lotNumber: 'LOT-B',
      expirationDate: DateTime(2026, 7, 1), // Vence en julio (más próximo!)
      entryDate: DateTime(2026, 2, 1),
      currentStock: 5.0,
      unitCost: 1.60,
    );

    final lotExpired = LotItem(
      id: 3,
      lotNumber: 'LOT-EXP',
      expirationDate: DateTime(2026, 5, 1), // Ya venció respecto a 2026-06-01
      entryDate: DateTime(2025, 12, 1),
      currentStock: 20.0,
      unitCost: 1.00,
    );

    test('Ordena correctamente priorizando la fecha de caducidad más cercana', () {
      final sorted = FefoComparator.sort([lot1, lot2]);
      expect(sorted.first.lotNumber, equals('LOT-B'));
      expect(sorted.last.lotNumber, equals('LOT-A'));
    });

    test('Filtra lotes vencidos o sin stock', () {
      final available = FefoComparator.filterAvailable([lot1, lot2, lotExpired], referenceDate: refDate);
      expect(available.length, equals(2));
      expect(available.any((l) => l.lotNumber == 'LOT-EXP'), isFalse);
    });

    test('Asigna stock secuencialmente desde los lotes más próximos a caducar', () {
      final allocations = FefoComparator.allocateStock(
        lots: [lot1, lot2],
        requestedQuantity: 8.0,
        referenceDate: refDate,
      );

      // Debe tomar primero todas las 5 unidades de LOT-B, y luego 3 unidades de LOT-A
      expect(allocations.length, equals(2));
      expect(allocations[0].lot.lotNumber, equals('LOT-B'));
      expect(allocations[0].quantityDeducted, equals(5.0));

      expect(allocations[1].lot.lotNumber, equals('LOT-A'));
      expect(allocations[1].quantityDeducted, equals(3.0));
    });

    test('Lanza StateError si el stock disponible no es suficiente', () {
      expect(
        () => FefoComparator.allocateStock(
          lots: [lot1, lot2],
          requestedQuantity: 50.0, // Solo hay 15 disponibles
          referenceDate: refDate,
        ),
        throwsStateError,
      );
    });
  });
}
