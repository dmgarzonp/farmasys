import 'purchase_item.dart';

/// Entidad inmutable de Factura de Compra y Recepción de Mercadería
class PurchaseInvoice {
  final int? id;
  final int proveedorId;
  final String proveedorNombre;
  final String proveedorRuc;
  final String numeroFactura;
  final String? numeroAutorizacionSri;
  final DateTime fechaEmision;
  final DateTime fechaRecepcion;
  final double subtotalDoce;
  final double subtotalCero;
  final double iva;
  final double total;
  final String? observaciones;
  final String estado; // 'ingresada' | 'anulada'
  final List<PurchaseItem> items;

  const PurchaseInvoice({
    this.id,
    required this.proveedorId,
    required this.proveedorNombre,
    required this.proveedorRuc,
    required this.numeroFactura,
    this.numeroAutorizacionSri,
    required this.fechaEmision,
    required this.fechaRecepcion,
    required this.subtotalDoce,
    required this.subtotalCero,
    required this.iva,
    required this.total,
    this.observaciones,
    this.estado = 'ingresada',
    this.items = const [],
  });

  int get itemCount => items.length;

  double get totalUnidades => items.fold(0.0, (acc, item) => acc + item.cantidadUnidades);

  /// Verifica si todos los ítems cumplen los requisitos del Acta Técnica ARCSA
  bool get todosConformesArcsa => items.every((i) => i.esConformeArcsa);

  PurchaseInvoice copyWith({
    int? id,
    int? proveedorId,
    String? proveedorNombre,
    String? proveedorRuc,
    String? numeroFactura,
    String? numeroAutorizacionSri,
    DateTime? fechaEmision,
    DateTime? fechaRecepcion,
    double? subtotalDoce,
    double? subtotalCero,
    double? iva,
    double? total,
    String? observaciones,
    String? estado,
    List<PurchaseItem>? items,
  }) {
    return PurchaseInvoice(
      id: id ?? this.id,
      proveedorId: proveedorId ?? this.proveedorId,
      proveedorNombre: proveedorNombre ?? this.proveedorNombre,
      proveedorRuc: proveedorRuc ?? this.proveedorRuc,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      numeroAutorizacionSri: numeroAutorizacionSri ?? this.numeroAutorizacionSri,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaRecepcion: fechaRecepcion ?? this.fechaRecepcion,
      subtotalDoce: subtotalDoce ?? this.subtotalDoce,
      subtotalCero: subtotalCero ?? this.subtotalCero,
      iva: iva ?? this.iva,
      total: total ?? this.total,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      items: items ?? this.items,
    );
  }
}
