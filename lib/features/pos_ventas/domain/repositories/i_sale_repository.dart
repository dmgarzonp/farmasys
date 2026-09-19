import '../entities/cart_item.dart';
import '../entities/sale.dart';

/// Contrato abstracto para el procesamiento de ventas en el Punto de Venta (SOLID: DIP)
abstract class ISaleRepository {
  /// Procesa una venta en una transacción SQLite atómica:
  /// 1. Asigna y deduce los lotes mediante el comparador FEFO en `IInventoryRepository`.
  /// 2. Registra el comprobante en `VentasTable`.
  /// 3. Registra cada renglón vinculado a su lote físico en `DetallesVentaTable`.
  /// 4. Si el pago es en efectivo, acumula el monto en la sesión de caja activa.
  Future<Sale> processSale({
    required Sale saleHeader,
    required List<CartItem> cartItems,
  });

  /// Consulta una venta por su ID interno con sus detalles completos
  Future<Sale?> getSaleById(int saleId);

  /// Consulta las ventas más recientes
  Future<List<Sale>> getRecentSales({int limit = 50});
}
