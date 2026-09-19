/// Entidad inmutable de lote físico e inventario farmacéutico (SOLID: SRP)
/// Desacoplada de cualquier motor de base de datos.
class BatchStock {
  final int? id;
  final int presentacionId;
  final String? productName;
  final String? presentationName;
  final String lote;
  final DateTime fechaVencimiento;
  final DateTime fechaIngreso;
  final double stockActual;
  final double precioCompraCaja;
  final double precioCompraUnitario;
  final String? ubicacion;

  const BatchStock({
    this.id,
    required this.presentacionId,
    this.productName,
    this.presentationName,
    required this.lote,
    required this.fechaVencimiento,
    required this.fechaIngreso,
    required this.stockActual,
    this.precioCompraCaja = 0.0,
    this.precioCompraUnitario = 0.0,
    this.ubicacion,
  });

  /// Días restantes antes del vencimiento
  int get daysUntilExpiration {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(fechaVencimiento.year, fechaVencimiento.month, fechaVencimiento.day);
    return expiry.difference(today).inDays;
  }

  /// Indica si el lote ya expiró
  bool get isExpired => daysUntilExpiration < 0;

  /// Indica si el lote está próximo a vencer (<= 90 días y vigente)
  bool get isExpiringSoon => daysUntilExpiration >= 0 && daysUntilExpiration <= 90;

  /// Indica si el lote está en período de riesgo moderado (91 a 180 días)
  bool get isExpiringMedium => daysUntilExpiration > 90 && daysUntilExpiration <= 180;

  /// Indica si el lote tiene vigencia óptima (> 180 días)
  bool get isOptimal => daysUntilExpiration > 180;

  BatchStock copyWith({
    int? id,
    int? presentacionId,
    String? productName,
    String? presentationName,
    String? lote,
    DateTime? fechaVencimiento,
    DateTime? fechaIngreso,
    double? stockActual,
    double? precioCompraCaja,
    double? precioCompraUnitario,
    String? ubicacion,
  }) {
    return BatchStock(
      id: id ?? this.id,
      presentacionId: presentacionId ?? this.presentacionId,
      productName: productName ?? this.productName,
      presentationName: presentationName ?? this.presentationName,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      stockActual: stockActual ?? this.stockActual,
      precioCompraCaja: precioCompraCaja ?? this.precioCompraCaja,
      precioCompraUnitario: precioCompraUnitario ?? this.precioCompraUnitario,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }
}
