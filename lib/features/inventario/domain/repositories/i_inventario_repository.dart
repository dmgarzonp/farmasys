import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/fefo_comparator.dart';

/// Contrato para operaciones de inventario, ajustes y kardex (SOLID: DIP & LSP)
abstract interface class IInventarioRepository {
  /// Obtiene los lotes activos de una presentación ordenados por FEFO
  Future<List<LotItem>> obtenerLotesPorPresentacion(int presentacionId);

  /// Obtiene todos los lotes próximos a vencer dentro del rango de días dado
  Future<List<LotItem>> obtenerLotesProximosAVencer({int dias = AppConstants.defaultExpirationAlertDays});

  /// Obtiene todos los lotes ya caducados que aún tengan stock > 0
  Future<List<LotItem>> obtenerLotesVencidos();

  /// Realiza un ajuste manual de inventario (favorable, desfavorable o merma)
  Future<void> registrarAjusteStock({
    required int loteId,
    required double cantidadAjuste,
    required StockMovementType tipo,
    required String motivo,
    required int usuarioId,
  });

  /// Da de baja definitiva a un lote vencido ajustando su stock a 0
  Future<void> darDeBajaLoteVencido({
    required int loteId,
    required String motivo,
    required int usuarioId,
  });
}
