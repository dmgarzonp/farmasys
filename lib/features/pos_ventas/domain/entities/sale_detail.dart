/// Entidad de dominio inmutable para el detalle de un ítem vendido (SOLID: SRP)
class SaleDetail {
  final int? id;
  final int ventaId;
  final int presentacionId;
  final int loteId;
  final String? loteCodigo;
  final String? productoNombre;
  final String? presentacionNombre;
  final double cantidad;
  final bool esFraccion;
  final double precioUnitario;
  final double descuento;
  final double subtotal;
  final double ivaTotal;

  const SaleDetail({
    this.id,
    required this.ventaId,
    required this.presentacionId,
    required this.loteId,
    this.loteCodigo,
    this.productoNombre,
    this.presentacionNombre,
    required this.cantidad,
    this.esFraccion = false,
    required this.precioUnitario,
    this.descuento = 0.0,
    required this.subtotal,
    this.ivaTotal = 0.0,
  });

  SaleDetail copyWith({
    int? id,
    int? ventaId,
    int? presentacionId,
    int? loteId,
    String? loteCodigo,
    String? productoNombre,
    String? presentacionNombre,
    double? cantidad,
    bool? esFraccion,
    double? precioUnitario,
    double? descuento,
    double? subtotal,
    double? ivaTotal,
  }) {
    return SaleDetail(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      presentacionId: presentacionId ?? this.presentacionId,
      loteId: loteId ?? this.loteId,
      loteCodigo: loteCodigo ?? this.loteCodigo,
      productoNombre: productoNombre ?? this.productoNombre,
      presentacionNombre: presentacionNombre ?? this.presentacionNombre,
      cantidad: cantidad ?? this.cantidad,
      esFraccion: esFraccion ?? this.esFraccion,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      descuento: descuento ?? this.descuento,
      subtotal: subtotal ?? this.subtotal,
      ivaTotal: ivaTotal ?? this.ivaTotal,
    );
  }
}
