import '../entities/cash_session.dart';

/// Contrato abstracto para la gestión de turnos y arqueos de caja (SOLID: DIP)
abstract class ICashSessionRepository {
  /// Obtiene la sesión activa de caja para un usuario o terminal (null si no hay caja abierta)
  Future<CashSession?> getActiveSession({int? usuarioId});

  /// Stream reactivo de la sesión de caja activa
  Stream<CashSession?> watchActiveSession({int? usuarioId});

  /// Abre un nuevo turno de caja con fondo inicial en efectivo
  Future<CashSession> openSession({
    required int usuarioId,
    required double montoInicial,
    String? observaciones,
  });

  /// Cierra el turno de caja actual y registra los montos finales del arqueo
  Future<CashSession> closeSession({
    required int sessionId,
    required double montoFinalEfectivo,
    double? montoFinalTarjeta,
    double? montoFinalTransferencia,
    String? observaciones,
  });

  /// Acumula una venta en efectivo al monto esperado de la sesión abierta
  Future<void> addCashSale(int sessionId, double amount);
}
