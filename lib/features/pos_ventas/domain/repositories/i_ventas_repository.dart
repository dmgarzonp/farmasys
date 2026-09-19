import '../entities/cart_item.dart';
import '../entities/payment_method.dart';

/// Contrato abstracto para el repositorio de ventas (SOLID: DIP & LSP)
abstract interface class IVentasRepository {
  /// Registra una nueva venta, descuenta los lotes asignados y genera los movimientos de stock
  Future<int> registrarVenta({
    required int usuarioId,
    required int sesionCajaId,
    int? clienteId,
    required List<CartItem> items,
    required PaymentMethodHandler paymentMethod,
    String? claveAccesoSri,
  });

  /// Obtiene el resumen de ventas de un turno de caja específico para el arqueo
  Future<Map<String, double>> obtenerResumenVentasTurno(int sesionCajaId);
}
