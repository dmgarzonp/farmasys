import '../entities/purchase_invoice.dart';

/// Contrato abstracto para el repositorio de compras y recepción de mercadería (SOLID: DIP)
abstract class IPurchaseRepository {
  /// Registra atómicamente la factura de compra, inserta los lotes físicos,
  /// asienta los movimientos de Kardex (entrada_compra) y actualiza los costos de compra.
  Future<PurchaseInvoice> registerPurchase(PurchaseInvoice invoice);

  /// Retorna el historial de compras filtrado opcionalmente por rango de fechas
  Future<List<PurchaseInvoice>> getPurchases({DateTime? from, DateTime? to});

  /// Obtiene una compra con todos sus renglones y datos de lote
  Future<PurchaseInvoice?> getPurchaseById(int id);

  /// Guarda temporalmente una factura en estado de borrador sin afectar Kardex ni precios
  Future<void> saveDraft(PurchaseInvoice invoice);

  /// Obtiene el borrador actual (si existe) para continuar el trabajo
  Future<PurchaseInvoice?> getDraft();

  /// Elimina el borrador actual de la base de datos
  Future<void> discardDraft();
}
