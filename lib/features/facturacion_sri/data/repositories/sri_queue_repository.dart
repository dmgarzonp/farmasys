import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/services/sri_xml_generator.dart';

final sriQueueRepositoryProvider = Provider<SriQueueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SriQueueRepository(db);
});

/// Representa una factura con todos sus datos de venta, cliente y detalles de productos
class SriInvoiceFullData {
  final VentasTableData venta;
  final ClientesTableData? cliente;
  final List<InvoiceDetail> details;

  SriInvoiceFullData({
    required this.venta,
    required this.cliente,
    required this.details,
  });
}

/// Repositorio encargado de gestionar la cola de facturación electrónica
class SriQueueRepository {
  final AppDatabase _db;

  SriQueueRepository(this._db);

  /// Obtiene un lote de ventas pendientes de procesar
  Future<List<VentasTableData>> getPendingInvoices({int limit = 5}) async {
    final query = _db.select(_db.ventasTable)
      ..where((tbl) => tbl.estadoSri.isIn(['pendiente', 'recibida']))
      ..orderBy([(t) => OrderingTerm.asc(t.fechaVenta)])
      ..limit(limit);
    return query.get();
  }

  /// Obtiene la información completa de una venta para generar el XML del SRI
  Future<SriInvoiceFullData?> getInvoiceFullData(int ventaId) async {
    final venta = await (_db.select(_db.ventasTable)..where((t) => t.id.equals(ventaId))).getSingleOrNull();
    if (venta == null) return null;

    ClientesTableData? cliente;
    if (venta.clienteId != null) {
      cliente = await (_db.select(_db.clientesTable)..where((t) => t.id.equals(venta.clienteId!))).getSingleOrNull();
    }

    final detailsQuery = _db.select(_db.detallesVentaTable).join([
      innerJoin(
        _db.presentacionesTable,
        _db.presentacionesTable.id.equalsExp(_db.detallesVentaTable.presentacionId),
      ),
      innerJoin(
        _db.productosTable,
        _db.productosTable.id.equalsExp(_db.presentacionesTable.productoId),
      ),
    ])..where(_db.detallesVentaTable.ventaId.equals(ventaId));

    final detailRows = await detailsQuery.get();
    final details = <InvoiceDetail>[];

    for (final row in detailRows) {
      final d = row.readTable(_db.detallesVentaTable);
      final pres = row.readTable(_db.presentacionesTable);
      final prod = row.readTable(_db.productosTable);

      final code = pres.codigoBarras ?? prod.codigoBarras ?? prod.id.toString();
      final desc = '${prod.nombreComercial} - ${pres.nombreDescriptivo}';

      details.add(InvoiceDetail(
        code: code,
        description: desc,
        quantity: d.cantidad,
        unitPrice: d.precioUnitario,
        discount: d.descuento,
        totalWithoutTax: d.subtotal,
      ));
    }

    return SriInvoiceFullData(
      venta: venta,
      cliente: cliente,
      details: details,
    );
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
