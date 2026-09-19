import '../../../../core/utils/fefo_comparator.dart';
import '../entities/batch_stock.dart';
import '../entities/stock_movement.dart';

/// Contrato abstracto para el repositorio de inventario, lotes y Kardex (SOLID: DIP).
/// Desacopla la lógica de almacenamiento y despacho FEFO de la base de datos subyacente.
abstract class IInventoryRepository {
  /// Obtiene todos los lotes con filtros opcionales
  Future<List<BatchStock>> getAllBatches({
    bool onlyWithStock = false,
    bool onlyExpiringSoon = false,
    bool onlyExpired = false,
  });

  /// Stream reactivo de lotes para la UI de inventario en tiempo real
  Stream<List<BatchStock>> watchAllBatches();

  /// Obtiene los lotes disponibles para una presentación ordenados por FEFO (más próximo a caducar primero)
  Future<List<BatchStock>> getBatchesForPresentation(int presentacionId);

  /// Registra el ingreso de un lote físico y genera automáticamente el movimiento Kardex de 'entrada_compra'
  Future<int> registerBatchEntry(
    BatchStock batch, {
    String? documentoReferencia,
    String? observaciones,
  });

  /// Ejecuta el algoritmo FEFO para despachar stock secuencialmente desde los lotes más próximos a vencer.
  /// Deduce el stock de cada lote y registra los movimientos de Kardex correspondientes dentro de una transacción atómica.
  Future<List<LotAllocation>> allocateFefoStock(
    int presentacionId,
    double requestedQuantity, {
    String? documentoReferencia,
  });

  /// Realiza un ajuste manual de inventario (positivo o negativo) con registro de auditoría
  Future<void> adjustStock(int batchId, double newStock, String motivo);

  /// Consulta el historial de movimientos de Kardex
  Future<List<StockMovement>> getKardexMovements({int? batchId, int limit = 100});
}
