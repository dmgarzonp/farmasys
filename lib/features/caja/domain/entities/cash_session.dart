/// Entidad inmutable para turnos y sesiones de caja (SOLID: SRP)
class CashSession {
  final int? id;
  final int usuarioId;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final double montoInicial;
  final double montoEsperadoEfectivo;
  final double? montoFinalEfectivo;
  final double? montoFinalTarjeta;
  final double? montoFinalTransferencia;
  final String estado; // 'abierta', 'cerrada'
  final String? observaciones;

  const CashSession({
    this.id,
    required this.usuarioId,
    required this.fechaApertura,
    this.fechaCierre,
    required this.montoInicial,
    this.montoEsperadoEfectivo = 0.0,
    this.montoFinalEfectivo,
    this.montoFinalTarjeta,
    this.montoFinalTransferencia,
    this.estado = 'abierta',
    this.observaciones,
  });

  bool get isOpen => estado == 'abierta';
  bool get isClosed => estado == 'cerrada';

  /// Diferencia de arqueo de efectivo (declarado - esperado)
  double? get cashDifference {
    if (montoFinalEfectivo == null) return null;
    return montoFinalEfectivo! - (montoInicial + montoEsperadoEfectivo);
  }

  CashSession copyWith({
    int? id,
    int? usuarioId,
    DateTime? fechaApertura,
    DateTime? fechaCierre,
    double? montoInicial,
    double? montoEsperadoEfectivo,
    double? montoFinalEfectivo,
    double? montoFinalTarjeta,
    double? montoFinalTransferencia,
    String? estado,
    String? observaciones,
  }) {
    return CashSession(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      montoInicial: montoInicial ?? this.montoInicial,
      montoEsperadoEfectivo: montoEsperadoEfectivo ?? this.montoEsperadoEfectivo,
      montoFinalEfectivo: montoFinalEfectivo ?? this.montoFinalEfectivo,
      montoFinalTarjeta: montoFinalTarjeta ?? this.montoFinalTarjeta,
      montoFinalTransferencia: montoFinalTransferencia ?? this.montoFinalTransferencia,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
