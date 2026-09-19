/// Entidad pura de presentación comercial de un producto farmacéutico (SOLID: SRP)
/// Desacoplada de cualquier motor de persistencia.
class ProductPresentation {
  final int? id;
  final int? productoId;
  final String nombreDescriptivo; // Ej: "Caja x 30 tabletas", "Frasco 120ml"
  final int unidadesPorCaja;
  final double precioCompraCaja;
  final double precioVentaCaja;
  final double precioVentaFraccion; // Precio unitario / suelto
  final int stockMinimo;
  final String? codigoBarras;
  final bool tieneIva; // false = 0%, true = 15%

  const ProductPresentation({
    this.id,
    this.productoId,
    required this.nombreDescriptivo,
    this.unidadesPorCaja = 1,
    this.precioCompraCaja = 0.0,
    required this.precioVentaCaja,
    this.precioVentaFraccion = 0.0,
    this.stockMinimo = 5,
    this.codigoBarras,
    this.tieneIva = false,
  });

  ProductPresentation copyWith({
    int? id,
    int? productoId,
    String? nombreDescriptivo,
    int? unidadesPorCaja,
    double? precioCompraCaja,
    double? precioVentaCaja,
    double? precioVentaFraccion,
    int? stockMinimo,
    String? codigoBarras,
    bool? tieneIva,
  }) {
    return ProductPresentation(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      nombreDescriptivo: nombreDescriptivo ?? this.nombreDescriptivo,
      unidadesPorCaja: unidadesPorCaja ?? this.unidadesPorCaja,
      precioCompraCaja: precioCompraCaja ?? this.precioCompraCaja,
      precioVentaCaja: precioVentaCaja ?? this.precioVentaCaja,
      precioVentaFraccion: precioVentaFraccion ?? this.precioVentaFraccion,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      tieneIva: tieneIva ?? this.tieneIva,
    );
  }
}

/// Entidad pura del catálogo de medicamentos y productos farmacéuticos (Clean Architecture)
class Product {
  final int? id;
  final String? codigoBarras;
  final String nombreComercial;
  final String? principioActivo;
  final String? concentracion;
  final int? laboratorioId;
  final int? categoriaId;
  final bool requiereReceta;
  final bool esPsicotropico;
  final bool esAntibiotico;
  final String estado; // 'activo' / 'inactivo'
  final List<ProductPresentation> presentaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    this.id,
    this.codigoBarras,
    required this.nombreComercial,
    this.principioActivo,
    this.concentracion,
    this.laboratorioId,
    this.categoriaId,
    this.requiereReceta = false,
    this.esPsicotropico = false,
    this.esAntibiotico = false,
    this.estado = 'activo',
    this.presentaciones = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => estado == 'activo';
  bool get hasArcsaAlert => requiereReceta || esPsicotropico || esAntibiotico;

  Product copyWith({
    int? id,
    String? codigoBarras,
    String? nombreComercial,
    String? principioActivo,
    String? concentracion,
    int? laboratorioId,
    int? categoriaId,
    bool? requiereReceta,
    bool? esPsicotropico,
    bool? esAntibiotico,
    String? estado,
    List<ProductPresentation>? presentaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      principioActivo: principioActivo ?? this.principioActivo,
      concentracion: concentracion ?? this.concentracion,
      laboratorioId: laboratorioId ?? this.laboratorioId,
      categoriaId: categoriaId ?? this.categoriaId,
      requiereReceta: requiereReceta ?? this.requiereReceta,
      esPsicotropico: esPsicotropico ?? this.esPsicotropico,
      esAntibiotico: esAntibiotico ?? this.esAntibiotico,
      estado: estado ?? this.estado,
      presentaciones: presentaciones ?? this.presentaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
