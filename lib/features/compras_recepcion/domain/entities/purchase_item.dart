/// Renglón individual de recepción de mercadería con control sanitario ARCSA
class PurchaseItem {
  final int? id;
  final int? compraId;
  final int presentacionId;
  final String productoNombre;
  final String presentacionNombre;
  final String? codigoBarras;
  final String lote;
  final DateTime fechaVencimiento;
  final double cantidadCajas;
  final double cantidadUnidades; // Unidades mínimas totales (Cajas * UnidadesPorCaja + sueltas)
  final int unidadesPorCaja;
  final double costoCaja;
  final double costoUnitario;
  final bool tieneIva;
  final double subtotal;

  // Verificación técnica sanitaria ARCSA
  final bool cumpleRegistroSanitario;
  final bool cumpleEmpaque;
  final double? temperaturaRecepcion; // Para medicamentos refrigerados (2°C - 8°C)

  const PurchaseItem({
    this.id,
    this.compraId,
    required this.presentacionId,
    required this.productoNombre,
    required this.presentacionNombre,
    this.codigoBarras,
    required this.lote,
    required this.fechaVencimiento,
    required this.cantidadCajas,
    required this.cantidadUnidades,
    required this.unidadesPorCaja,
    required this.costoCaja,
    required this.costoUnitario,
    required this.tieneIva,
    required this.subtotal,
    this.cumpleRegistroSanitario = true,
    this.cumpleEmpaque = true,
    this.temperaturaRecepcion,
  });

  /// Indica si cumple todos los criterios del Acta de Recepción Técnica ARCSA
  bool get esConformeArcsa => cumpleRegistroSanitario && cumpleEmpaque;

  PurchaseItem copyWith({
    int? id,
    int? compraId,
    int? presentacionId,
    String? productoNombre,
    String? presentacionNombre,
    String? codigoBarras,
    String? lote,
    DateTime? fechaVencimiento,
    double? cantidadCajas,
    double? cantidadUnidades,
    int? unidadesPorCaja,
    double? costoCaja,
    double? costoUnitario,
    bool? tieneIva,
    double? subtotal,
    bool? cumpleRegistroSanitario,
    bool? cumpleEmpaque,
    double? temperaturaRecepcion,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      compraId: compraId ?? this.compraId,
      presentacionId: presentacionId ?? this.presentacionId,
      productoNombre: productoNombre ?? this.productoNombre,
      presentacionNombre: presentacionNombre ?? this.presentacionNombre,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      cantidadCajas: cantidadCajas ?? this.cantidadCajas,
      cantidadUnidades: cantidadUnidades ?? this.cantidadUnidades,
      unidadesPorCaja: unidadesPorCaja ?? this.unidadesPorCaja,
      costoCaja: costoCaja ?? this.costoCaja,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      tieneIva: tieneIva ?? this.tieneIva,
      subtotal: subtotal ?? this.subtotal,
      cumpleRegistroSanitario: cumpleRegistroSanitario ?? this.cumpleRegistroSanitario,
      cumpleEmpaque: cumpleEmpaque ?? this.cumpleEmpaque,
      temperaturaRecepcion: temperaturaRecepcion ?? this.temperaturaRecepcion,
    );
  }
}
