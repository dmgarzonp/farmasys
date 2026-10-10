import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';

final sriQueueRepositoryProvider = Provider<SriQueueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SriQueueRepository(db);
});

/// Repositorio encargado de gestionar la cola de facturación electrónica
class SriQueueRepository {
  final AppDatabase _db;

  SriQueueRepository(this._db);

  /// Obtiene un lote de ventas pendientes de procesar
  Future<List<Venta>> getPendingInvoices({int limit = 5}) async {
    final query = _db.select(_db.ventasTable)
      ..where((tbl) => tbl.estadoSri.isIn(['pendiente', 'recibida']))
      ..orderBy([(t) => OrderingTerm.asc(t.fechaVenta)])
      ..limit(limit);
    return query.get();
  }

  /// Actualiza el estado SRI de una venta
  Future<void> updateSriStatus({
    required int ventaId,
    required String estadoSri,
    String? claveAcceso,
    String? mensajeSri,
  }) async {
    await (_db.update(_db.ventasTable)..where((tbl) => tbl.id.equals(ventaId))).write(
      VentasTableCompanion(
        estadoSri: Value(estadoSri),
        claveAcceso: claveAcceso != null ? Value(claveAcceso) : const Value.absent(),
        mensajeSri: mensajeSri != null ? Value(mensajeSri) : const Value.absent(),
      ),
    );
  }
}
