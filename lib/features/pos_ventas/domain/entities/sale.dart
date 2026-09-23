import 'sale_detail.dart';

/// Entidad inmutable de Factura / Venta en Punto de Venta (SOLID: SRP)
class Sale {
  final int? id;
  final int? clienteId;
  final String? clienteNombre;
  final String? clienteDocumento;
  final int usuarioId;
  final int sesionCajaId;
  final DateTime fechaVenta;

  // Desglose financiero (IVA 15% y 0%)
  final double subtotal0;
  final double subtotal12;
  final double descuentoTotal;
  final double impuestoTotal; // IVA 15%
  final double total;

  final String metodoPago; // 'efectivo', 'tarjeta', 'transferencia'
  final String? claveAcceso;
  final String estadoSri; // 'pendiente', 'autorizado', 'rechazado'
  final String? mensajeSri;

  final List<SaleDetail> detalles;

  const Sale({
    this.id,
    this.clienteId,
    this.clienteNombre,
    this.clienteDocumento,
    required this.usuarioId,
    required this.sesionCajaId,
    required this.fechaVenta,
    required this.subtotal0,
    required this.subtotal12,
    this.descuentoTotal = 0.0,
    required this.impuestoTotal,
    required this.total,
    this.metodoPago = 'efectivo',
    this.claveAcceso,
    this.estadoSri = 'autorizado', // Fijo como autorizado/datos fijos
    this.mensajeSri,
    this.detalles = const [],
  });

  Sale copyWith({
    int? id,
    int? clienteId,
    String? clienteNombre,
    String? clienteDocumento,
    int? usuarioId,
    int? sesionCajaId,
    DateTime? fechaVenta,
    double? subtotal0,
    double? subtotal12,
    double? descuentoTotal,
    double? impuestoTotal,
    double? total,
    String? metodoPago,
    String? claveAcceso,
    String? estadoSri,
    String? mensajeSri,
    List<SaleDetail>? detalles,
  }) {
    return Sale(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteDocumento: clienteDocumento ?? this.clienteDocumento,
      usuarioId: usuarioId ?? this.usuarioId,
      sesionCajaId: sesionCajaId ?? this.sesionCajaId,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      subtotal0: subtotal0 ?? this.subtotal0,
      subtotal12: subtotal12 ?? this.subtotal12,
      descuentoTotal: descuentoTotal ?? this.descuentoTotal,
      impuestoTotal: impuestoTotal ?? this.impuestoTotal,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      claveAcceso: claveAcceso ?? this.claveAcceso,
      estadoSri: estadoSri ?? this.estadoSri,
      mensajeSri: mensajeSri ?? this.mensajeSri,
      detalles: detalles ?? this.detalles,
    );
  }
}
