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

  /// Ganancia del Día (Ventas - Costos)
  Future<double> getGananciaHoy() async {
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

    final query = _db.select(_db.detallesVentaTable).join([
      innerJoin(_db.ventasTable, _db.ventasTable.id.equalsExp(_db.detallesVentaTable.ventaId)),
      innerJoin(_db.lotesTable, _db.lotesTable.id.equalsExp(_db.detallesVentaTable.loteId)),
    ])..where(_db.ventasTable.fechaVenta.isBetweenValues(inicioDia, finDia));

    final rows = await query.get();
    double gananciaTotal = 0;

    for (final row in rows) {
      final detalle = row.readTable(_db.detallesVentaTable);
      final lote = row.readTable(_db.lotesTable);
      
      final costo = lote.precioCompraUnitario * detalle.cantidad;
      final ingreso = (detalle.precioUnitario * detalle.cantidad) - detalle.descuento;
      
      gananciaTotal += (ingreso - costo);
    }
    
    return gananciaTotal;
  }

  /// Top 5 Productos Más Vendidos (últimos 30 días)
  Future<List<ProductoTop>> getTopProductosMes() async {
    final inicioMes = DateTime.now().subtract(const Duration(days: 30));
    
    final sql = '''
      SELECT 
        p.nombre_comercial as productoNombre,
        pr.nombre_descriptivo as presentacionNombre,
        SUM(dv.cantidad) as cantidadVendida,
        SUM((dv.precio_unitario * dv.cantidad) - dv.descuento) as totalRecaudado
      FROM detalles_venta dv
      INNER JOIN ventas v ON v.id = dv.venta_id
      INNER JOIN presentaciones pr ON pr.id = dv.presentacion_id
      INNER JOIN productos p ON p.id = pr.producto_id
      WHERE v.fecha_venta >= ?
      GROUP BY pr.id
      ORDER BY cantidadVendida DESC
      LIMIT 5;
    ''';
    
    final result = await _db.customSelect(sql, variables: [Variable.withDateTime(inicioMes)]).get();

    return result.map((row) {
      return ProductoTop(
        productoNombre: row.read<String>('productoNombre'),
        presentacionNombre: row.read<String>('presentacionNombre'),
        cantidadVendida: row.read<double>('cantidadVendida'),
        totalRecaudado: row.read<double>('totalRecaudado'),
      );
    }).toList();
  }

  /// Cantidad de Tickets y Ticket Promedio del día
  Future<(int, double)> getEstadisticasTicketsHoy() async {
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

    final query = _db.select(_db.ventasTable)
      ..where((t) => t.fechaVenta.isBetweenValues(inicioDia, finDia));
      
    final ventas = await query.get();
    if (ventas.isEmpty) return (0, 0.0);
    
    final total = ventas.fold<double>(0.0, (sum, v) => sum + v.total);
    return (ventas.length, total / ventas.length);
  }

  /// Capital invertido en el inventario actual (Stock * Costo)
  Future<double> getCapitalInventario() async {
    final sql = '''
      SELECT COALESCE(SUM(stock_actual * precio_compra_unitario), 0) as capital
      FROM lotes
      WHERE stock_actual > 0;
    ''';
    
    final result = await _db.customSelect(sql).getSingle();
    return result.read<double>('capital');
  }
}

