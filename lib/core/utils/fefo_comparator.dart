/// Representación mínima de un lote para el motor de asignación FEFO
class LotItem {
  final int id;
  final String lotNumber;
  final DateTime expirationDate;
  final DateTime entryDate;
  final double currentStock;
  final double unitCost;

  const LotItem({
    required this.id,
    required this.lotNumber,
    required this.expirationDate,
    required this.entryDate,
    required this.currentStock,
    required this.unitCost,
  });

  bool isExpired([DateTime? now]) {
    final DateTime current = now ?? DateTime.now();
    return expirationDate.isBefore(DateTime(current.year, current.month, current.day));
  }
}

/// Asignación parcial de un lote en una venta o salida
class LotAllocation {
  final LotItem lot;
  final double quantityDeducted;

  const LotAllocation({
    required this.lot,
    required this.quantityDeducted,
  });
}

/// Comparador y motor de despacho FEFO (First Expired, First Out)
/// Garantiza que siempre se despachen los medicamentos más antiguos o próximos a caducar.
class FefoComparator {
  FefoComparator._();

  /// Compara dos lotes según FEFO:
  /// 1. Vencimiento más cercano primero.
  /// 2. En caso de empate, fecha de ingreso más antigua primero.
  static int compare(LotItem a, LotItem b) {
    final int dateComparison = a.expirationDate.compareTo(b.expirationDate);
    if (dateComparison != 0) return dateComparison;
    return a.entryDate.compareTo(b.entryDate);
  }

  /// Ordena una lista de lotes aplicando la política FEFO.
  static List<LotItem> sort(List<LotItem> lots) {
    final List<LotItem> sorted = List<LotItem>.from(lots);
    sorted.sort(compare);
    return sorted;
  }

  /// Filtra lotes aptos para la venta (con stock positivo y no vencidos).
  static List<LotItem> filterAvailable(List<LotItem> lots, {DateTime? referenceDate}) {
    final DateTime ref = referenceDate ?? DateTime.now();
    return lots.where((lot) => lot.currentStock > 0 && !lot.isExpired(ref)).toList();
  }

  /// Asigna automáticamente qué lotes y qué cantidades deben descontarse
  /// para cubrir una cantidad solicitada según la regla FEFO.
  static List<LotAllocation> allocateStock({
    required List<LotItem> lots,
    required double requestedQuantity,
    DateTime? referenceDate,
  }) {
    if (requestedQuantity <= 0) return [];

    final List<LotItem> sortedAvailable = sort(filterAvailable(lots, referenceDate: referenceDate));
    final List<LotAllocation> allocations = [];
    double pendingQuantity = requestedQuantity;

    for (final lot in sortedAvailable) {
      if (pendingQuantity <= 0) break;

      final double availableInLot = lot.currentStock;
      final double toDeduct = (availableInLot >= pendingQuantity) ? pendingQuantity : availableInLot;

      allocations.add(LotAllocation(lot: lot, quantityDeducted: toDeduct));
      pendingQuantity -= toDeduct;
    }

    if (pendingQuantity > 0) {
      throw StateError(
        'Stock insuficiente: Se solicitaron $requestedQuantity unidades pero solo hay disponibles ${requestedQuantity - pendingQuantity}.',
      );
    }

    return allocations;
  }
}
