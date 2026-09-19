import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../domain/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DashboardRepository(db);
});

class DashboardRepository {
  final AppDatabase _db;

  DashboardRepository(this._db);

  /// Obtiene los lotes que vencen en los próximos [diasAlerta] días y tienen stock > 0.
  Future<List<AlertaCaducidad>> getLotesPorCaducar({int diasAlerta = 90}) async {
    final fechaLimite = DateTime.now().add(Duration(days: diasAlerta));

    final query = _db.select(_db.lotesTable).join([
      innerJoin(
        _db.presentacionesTable,
        _db.presentacionesTable.id.equalsExp(_db.lotesTable.presentacionId),
      ),
      innerJoin(
        _db.productosTable,
        _db.productosTable.id.equalsExp(_db.presentacionesTable.productoId),
      ),
    ])
      ..where(_db.lotesTable.stockActual.isBiggerThan(const Constant(0.0)))
      ..where(_db.lotesTable.fechaVencimiento.isSmallerOrEqualValue(fechaLimite))
      ..orderBy([OrderingTerm.asc(_db.lotesTable.fechaVencimiento)]);

    final rows = await query.get();

    return rows.map((row) {
      final lote = row.readTable(_db.lotesTable);
      final presentacion = row.readTable(_db.presentacionesTable);
      final producto = row.readTable(_db.productosTable);

      return AlertaCaducidad(
        productoNombre: producto.nombreComercial,
        presentacionNombre: presentacion.nombreDescriptivo,
        lote: lote.lote,
        fechaVencimiento: lote.fechaVencimiento,
        stockActual: lote.stockActual,
      );
    }).toList();
  }

  /// Obtiene presentaciones cuyo stock total (sumando todos sus lotes) es menor o igual al stock mínimo.
  Future<List<AlertaStock>> getProductosStockBajo() async {
    // Usamos custom statement porque agrupar y sumar con joins en Drift typed API puede ser verboso.
    final sql = '''
      SELECT 
        p.id as producto_id,
        p.nombre_comercial as nombreComercial,
        pr.id as presentacion_id,
        pr.nombre_descriptivo as nombreDescriptivo,
        pr.stock_minimo as stockMinimo,
        COALESCE(SUM(l.stock_actual), 0) as stockTotal
      FROM presentaciones pr
      INNER JOIN productos p ON p.id = pr.producto_id
      LEFT JOIN lotes l ON l.presentacion_id = pr.id
      GROUP BY pr.id
      HAVING stockTotal <= pr.stock_minimo
      ORDER BY stockTotal ASC;
    ''';

    final result = await _db.customSelect(sql).get();

    return result.map((row) {
      return AlertaStock(
        productoNombre: row.read<String>('nombreComercial'),
        presentacionNombre: row.read<String>('nombreDescriptivo'),
        stockMinimo: row.read<int>('stockMinimo'),
        stockTotal: row.read<double>('stockTotal'),
      );
    }).toList();
  }
  
  /// (Opcional) Obtener total de ventas del día actual
  Future<double> getTotalVentasHoy() async {
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

    final query = _db.select(_db.ventasTable)
      ..where((t) => t.fechaVenta.isBetweenValues(inicioDia, finDia));

    final ventas = await query.get();
    return ventas.fold<double>(0.0, (sum, v) => sum + (v.total ?? 0.0));
  }
}
