import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/drift_cash_session_repository.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/i_cash_session_repository.dart';

/// Estado inmutable de la sesión de caja activa
class CashSessionState {
  final CashSession? activeSession;
  final bool isLoading;
  final String? errorMessage;

  const CashSessionState({
    this.activeSession,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasActiveSession => activeSession != null && activeSession!.isOpen;

  CashSessionState copyWith({
    CashSession? activeSession,
    bool? isLoading,
    String? errorMessage,
    bool clearActiveSession = false,
  }) {
    return CashSessionState(
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controlador Riverpod para la sesión de caja del cajero actual (SOLID: SRP)
class CashSessionNotifier extends StateNotifier<CashSessionState> {
  final ICashSessionRepository _repository;

  CashSessionNotifier(this._repository) : super(const CashSessionState()) {
    loadActiveSession();
  }

  /// Carga la sesión activa actual
  Future<void> loadActiveSession() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final session = await _repository.getActiveSession();
      state = state.copyWith(
        activeSession: session,
        clearActiveSession: session == null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al consultar turno de caja: $e',
      );
    }
  }

  /// Abre un nuevo turno de caja
  Future<bool> openSession({
    required double montoInicial,
    String? observaciones,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newSession = await _repository.openSession(
        usuarioId: 1, // Usuario cajero predeterminado
        montoInicial: montoInicial,
        observaciones: observaciones,
      );
      state = state.copyWith(
        activeSession: newSession,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al abrir caja: $e',
      );
      return false;
    }
  }

  /// Cierra el turno de caja y registra el arqueo
  Future<bool> closeSession({
    required double montoFinalEfectivo,
    double? montoFinalTarjeta,
    double? montoFinalTransferencia,
    String? observaciones,
  }) async {
    if (state.activeSession?.id == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.closeSession(
        sessionId: state.activeSession!.id!,
        montoFinalEfectivo: montoFinalEfectivo,
        montoFinalTarjeta: montoFinalTarjeta,
        montoFinalTransferencia: montoFinalTransferencia,
        observaciones: observaciones,
      );
      state = state.copyWith(
        clearActiveSession: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cerrar caja: $e',
      );
      return false;
    }
  }
}

/// Proveedor Riverpod para el estado de la sesión de caja
final cashSessionProvider = StateNotifierProvider<CashSessionNotifier, CashSessionState>((ref) {
  final repo = ref.watch(cashSessionRepositoryProvider);
  return CashSessionNotifier(repo);
});
