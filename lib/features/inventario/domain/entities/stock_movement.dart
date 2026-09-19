/// Entidad inmutable de movimiento de stock para auditoría y Kardex (SOLID: SRP)
class StockMovement {
  final int? id;
  final String tipo; // 'entrada_compra', 'salida_venta', 'ajuste_positivo', 'ajuste_negativo', 'merma_caducado'
  final int loteId;
  final String? loteCode;
  final String? productName;
  final double cantidad;
  final String? documentoReferencia;
  final DateTime fechaMovimiento;
  final int? usuarioId;
  final String? observaciones;

  const StockMovement({
    this.id,
    required this.tipo,
    required this.loteId,
    this.loteCode,
    this.productName,
    required this.cantidad,
    this.documentoReferencia,
    required this.fechaMovimiento,
    this.usuarioId,
    this.observaciones,
  });

  bool get isEntry => tipo.startsWith('entrada') || tipo == 'ajuste_positivo';
  bool get isExit => tipo.startsWith('salida') || tipo == 'ajuste_negativo' || tipo.contains('merma');
}
