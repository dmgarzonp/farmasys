import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/i_cash_session_repository.dart';

/// Implementación desacoplada del control de turnos de caja con Drift (SQLite).
class DriftCashSessionRepository implements ICashSessionRepository {
  final AppDatabase _db;

  DriftCashSessionRepository(this._db);

  @override
  Future<CashSession?> getActiveSession({int? usuarioId}) async {
    final query = _db.select(_db.cajasSesionesTable)
      ..where((tbl) => tbl.estado.equals('abierta'));

    if (usuarioId != null) {
      query.where((tbl) => tbl.usuarioId.equals(usuarioId));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.fechaApertura)]);
    query.limit(1);

    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRowToEntity(row);
  }

  @override
  Stream<CashSession?> watchActiveSession({int? usuarioId}) {
    final query = _db.select(_db.cajasSesionesTable)
      ..where((tbl) => tbl.estado.equals('abierta'));

    if (usuarioId != null) {
      query.where((tbl) => tbl.usuarioId.equals(usuarioId));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.fechaApertura)]);
    query.limit(1);

    return query.watchSingleOrNull().map((row) => row == null ? null : _mapRowToEntity(row));
  }

  @override
  Future<CashSession> openSession({
    required int usuarioId,
    required double montoInicial,
    String? observaciones,
  }) async {
    // 1. Verificar si ya existe una sesión abierta
    final existing = await getActiveSession(usuarioId: usuarioId);
    if (existing != null) {
      throw StateError('Ya existe una sesión de caja abierta (#${existing.id}).');
    }

    // 2. Insertar nueva sesión
    final id = await _db.into(_db.cajasSesionesTable).insert(
          CajasSesionesTableCompanion.insert(
            usuarioId: usuarioId,
            montoInicial: Value(montoInicial),
            montoEsperadoEfectivo: const Value(0.0),
            estado: const Value('abierta'),
            observaciones: Value(observaciones),
          ),
        );

    final created = await (_db.select(_db.cajasSesionesTable)..where((t) => t.id.equals(id))).getSingle();
    return _mapRowToEntity(created);
  }

  @override
  Future<CashSession> closeSession({
    required int sessionId,
    required double montoFinalEfectivo,
    double? montoFinalTarjeta,
    double? montoFinalTransferencia,
    String? observaciones,
  }) async {
    final now = DateTime.now();

    await (_db.update(_db.cajasSesionesTable)..where((tbl) => tbl.id.equals(sessionId))).write(
      CajasSesionesTableCompanion(
        estado: const Value('cerrada'),
        fechaCierre: Value(now),
        montoFinalEfectivo: Value(montoFinalEfectivo),
        montoFinalTarjeta: Value(montoFinalTarjeta),
        montoFinalTransferencia: Value(montoFinalTransferencia),
        observaciones: Value(observaciones),
      ),
    );

    final closed = await (_db.select(_db.cajasSesionesTable)..where((t) => t.id.equals(sessionId))).getSingle();
    return _mapRowToEntity(closed);
  }

  @override
  Future<void> addCashSale(int sessionId, double amount) async {
    final current = await (_db.select(_db.cajasSesionesTable)..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (current == null) return;

    final updatedAmount = current.montoEsperadoEfectivo + amount;
    await (_db.update(_db.cajasSesionesTable)..where((t) => t.id.equals(sessionId))).write(
      CajasSesionesTableCompanion(
        montoEsperadoEfectivo: Value(updatedAmount),
      ),
    );
  }

  CashSession _mapRowToEntity(CajasSesionesTableData row) {
    return CashSession(
      id: row.id,
      usuarioId: row.usuarioId,
      fechaApertura: row.fechaApertura,
      fechaCierre: row.fechaCierre,
      montoInicial: row.montoInicial,
      montoEsperadoEfectivo: row.montoEsperadoEfectivo,
      montoFinalEfectivo: row.montoFinalEfectivo,
      montoFinalTarjeta: row.montoFinalTarjeta,
      montoFinalTransferencia: row.montoFinalTransferencia,
      estado: row.estado,
      observaciones: row.observaciones,
    );
  }
}

/// Proveedor Riverpod para ICashSessionRepository
final cashSessionRepositoryProvider = Provider<ICashSessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftCashSessionRepository(db);
});
