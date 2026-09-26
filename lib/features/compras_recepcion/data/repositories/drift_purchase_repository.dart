import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/purchase_invoice.dart';
import '../../domain/entities/purchase_item.dart';
import '../../domain/repositories/i_purchase_repository.dart';

/// Implementación desacoplada del repositorio de compras con Drift (SQLite en background isolate)
class DriftPurchaseRepository implements IPurchaseRepository {
  final AppDatabase _db;

  DriftPurchaseRepository(this._db);

  @override
  Future<PurchaseInvoice> registerPurchase(PurchaseInvoice invoice) async {
    return await _db.transaction(() async {
      final finalState = invoice.todosConformesArcsa ? 'ingresada' : 'observada';
      final compraId = await _db.into(_db.comprasTable).insert(
            ComprasTableCompanion.insert(
              proveedorId: invoice.proveedorId,
              numeroFactura: invoice.numeroFactura.trim(),
              numeroAutorizacionSri: Value(invoice.numeroAutorizacionSri?.trim()),
              fechaEmision: invoice.fechaEmision,
              fechaRecepcion: Value(invoice.fechaRecepcion),
              subtotalDoce: Value(invoice.subtotalDoce),
              subtotalCero: Value(invoice.subtotalCero),
              iva: Value(invoice.iva),
              total: Value(invoice.total),
              observaciones: Value(invoice.observaciones?.trim()),
              estado: Value(finalState),
            ),
          );

      final registeredItems = <PurchaseItem>[];

      // 2. Procesar cada renglón de compra
      for (final item in invoice.items) {
        // a) Guardar detalle de compra
        final detalleId = await _db.into(_db.detallesCompraTable).insert(
              DetallesCompraTableCompanion.insert(
                compraId: compraId,
                presentacionId: item.presentacionId,
                lote: item.lote.trim().toUpperCase(),
                fechaVencimiento: item.fechaVencimiento,
                cantidadCajas: Value(item.cantidadCajas),
                cantidadUnidades: Value(item.cantidadUnidades),
                costoCaja: Value(item.costoCaja),
                costoUnitario: Value(item.costoUnitario),
                subtotal: Value(item.subtotal),
                cumpleRegistroSanitario: Value(item.cumpleRegistroSanitario),
                cumpleEmpaque: Value(item.cumpleEmpaque),
                temperaturaRecepcion: Value(item.temperaturaRecepcion),
              ),
            );

        // b) Asentar o actualizar el lote físico en inventario
        final existingLote = await (_db.select(_db.lotesTable)
              ..where((t) =>
                  t.presentacionId.equals(item.presentacionId) &
                  t.lote.equals(item.lote.trim().toUpperCase())))
            .getSingleOrNull();

        int loteId;
        if (existingLote != null) {
          loteId = existingLote.id;
          await (_db.update(_db.lotesTable)..where((t) => t.id.equals(loteId))).write(
            LotesTableCompanion(
              stockActual: Value(existingLote.stockActual + item.cantidadUnidades),
              precioCompraCaja: Value(item.costoCaja),
              precioCompraUnitario: Value(item.costoUnitario),
            ),
          );
        } else {
          loteId = await _db.into(_db.lotesTable).insert(
                LotesTableCompanion.insert(
                  presentacionId: item.presentacionId,
                  lote: item.lote.trim().toUpperCase(),
                  fechaVencimiento: item.fechaVencimiento,
                  fechaIngreso: Value(invoice.fechaRecepcion),
                  stockActual: Value(item.cantidadUnidades),
                  precioCompraCaja: Value(item.costoCaja),
                  precioCompraUnitario: Value(item.costoUnitario),
                ),
              );
        }

        // c) Asentar movimiento auditado en el Kardex (Entrada por Compra)
        await _db.into(_db.movimientosStockTable).insert(
              MovimientosStockTableCompanion.insert(
                tipo: StockMovementType.entradaCompra.code,
                loteId: loteId,
                cantidad: item.cantidadUnidades,
                documentoReferencia: Value('Factura #${invoice.numeroFactura} - ${invoice.proveedorNombre}'),
                fechaMovimiento: Value(invoice.fechaRecepcion),
                observaciones: Value('Recepción de compra - ${item.cantidadCajas} cajas (${item.cantidadUnidades} unidades)'),
              ),
            );

        // d) Actualizar el último costo de compra en el catálogo maestro
        await (_db.update(_db.presentacionesTable)..where((t) => t.id.equals(item.presentacionId))).write(
          PresentacionesTableCompanion(
            precioCompraCaja: Value(item.costoCaja),
          ),
        );

        registeredItems.add(item.copyWith(id: detalleId, compraId: compraId));
      }

      return invoice.copyWith(id: compraId, items: registeredItems);
    });
  }

  @override
  Future<List<PurchaseInvoice>> getPurchases({DateTime? from, DateTime? to}) async {
    final query = _db.select(_db.comprasTable).join([
      innerJoin(_db.proveedoresTable, _db.proveedoresTable.id.equalsExp(_db.comprasTable.proveedorId)),
    ]);

    if (from != null) {
      query.where(_db.comprasTable.fechaRecepcion.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(_db.comprasTable.fechaRecepcion.isSmallerOrEqualValue(to));
    }

    query.orderBy([OrderingTerm.desc(_db.comprasTable.id)]);

    final rows = await query.get();

    return rows.map((row) {
      final compra = row.readTable(_db.comprasTable);
      final proveedor = row.readTable(_db.proveedoresTable);

      return PurchaseInvoice(
        id: compra.id,
        proveedorId: compra.proveedorId,
        proveedorNombre: proveedor.nombreEmpresa,
        proveedorRuc: proveedor.ruc,
        numeroFactura: compra.numeroFactura,
        numeroAutorizacionSri: compra.numeroAutorizacionSri,
        fechaEmision: compra.fechaEmision,
        fechaRecepcion: compra.fechaRecepcion,
        subtotalDoce: compra.subtotalDoce,
        subtotalCero: compra.subtotalCero,
        iva: compra.iva,
        total: compra.total,
        observaciones: compra.observaciones,
        estado: compra.estado,
        items: const [],
      );
    }).toList();
  }

  @override
  Future<PurchaseInvoice?> getPurchaseById(int id) async {
    final compraRow = await (_db.select(_db.comprasTable).join([
      innerJoin(_db.proveedoresTable, _db.proveedoresTable.id.equalsExp(_db.comprasTable.proveedorId)),
    ])..where(_db.comprasTable.id.equals(id)))
        .getSingleOrNull();

    if (compraRow == null) return null;

    final compra = compraRow.readTable(_db.comprasTable);
    final proveedor = compraRow.readTable(_db.proveedoresTable);

    // Obtener detalles con datos de presentación y producto
    final detallesQuery = _db.select(_db.detallesCompraTable).join([
      innerJoin(_db.presentacionesTable, _db.presentacionesTable.id.equalsExp(_db.detallesCompraTable.presentacionId)),
      innerJoin(_db.productosTable, _db.productosTable.id.equalsExp(_db.presentacionesTable.productoId)),
    ])..where(_db.detallesCompraTable.compraId.equals(id));

    final detalleRows = await detallesQuery.get();

    final items = detalleRows.map((row) {
      final det = row.readTable(_db.detallesCompraTable);
      final pres = row.readTable(_db.presentacionesTable);
      final prod = row.readTable(_db.productosTable);

      return PurchaseItem(
        id: det.id,
        compraId: det.compraId,
        presentacionId: det.presentacionId,
        productoNombre: prod.nombreComercial,
        presentacionNombre: pres.nombreDescriptivo,
        codigoBarras: pres.codigoBarras,
        lote: det.lote,
        fechaVencimiento: det.fechaVencimiento,
        cantidadCajas: det.cantidadCajas,
        cantidadUnidades: det.cantidadUnidades,
        unidadesPorCaja: pres.unidadesPorCaja,
        costoCaja: det.costoCaja,
        costoUnitario: det.costoUnitario,
        tieneIva: pres.tieneIva,
        subtotal: det.subtotal,
        cumpleRegistroSanitario: det.cumpleRegistroSanitario,
        cumpleEmpaque: det.cumpleEmpaque,
        temperaturaRecepcion: det.temperaturaRecepcion,
      );
    }).toList();

    return PurchaseInvoice(
      id: compra.id,
      proveedorId: compra.proveedorId,
      proveedorNombre: proveedor.nombreEmpresa,
      proveedorRuc: proveedor.ruc,
      numeroFactura: compra.numeroFactura,
      numeroAutorizacionSri: compra.numeroAutorizacionSri,
      fechaEmision: compra.fechaEmision,
      fechaRecepcion: compra.fechaRecepcion,
      subtotalDoce: compra.subtotalDoce,
      subtotalCero: compra.subtotalCero,
      iva: compra.iva,
      total: compra.total,
      observaciones: compra.observaciones,
      estado: compra.estado,
      items: items,
    );
  }
  @override
  Future<PurchaseInvoice> saveDraft(PurchaseInvoice invoice) async {
    return await _db.transaction(() async {
      int compraId;
      
      if (invoice.id != null) {
        compraId = invoice.id!;
        await (_db.update(_db.comprasTable)..where((t) => t.id.equals(compraId))).write(
          ComprasTableCompanion(
            proveedorId: Value(invoice.proveedorId),
            numeroFactura: Value(invoice.numeroFactura.trim()),
            numeroAutorizacionSri: Value(invoice.numeroAutorizacionSri?.trim()),
            fechaEmision: Value(invoice.fechaEmision),
            fechaRecepcion: Value(invoice.fechaRecepcion),
            subtotalDoce: Value(invoice.subtotalDoce),
            subtotalCero: Value(invoice.subtotalCero),
            iva: Value(invoice.iva),
            total: Value(invoice.total),
            observaciones: Value(invoice.observaciones?.trim()),
            estado: const Value('borrador'),
          ),
        );
        // Borrar items antiguos
        await (_db.delete(_db.detallesCompraTable)..where((t) => t.compraId.equals(compraId))).go();
      } else {
        compraId = await _db.into(_db.comprasTable).insert(
          ComprasTableCompanion.insert(
            proveedorId: invoice.proveedorId,
            numeroFactura: invoice.numeroFactura.trim(),
            numeroAutorizacionSri: Value(invoice.numeroAutorizacionSri?.trim()),
            fechaEmision: invoice.fechaEmision,
            fechaRecepcion: Value(invoice.fechaRecepcion),
            subtotalDoce: Value(invoice.subtotalDoce),
            subtotalCero: Value(invoice.subtotalCero),
            iva: Value(invoice.iva),
            total: Value(invoice.total),
            observaciones: Value(invoice.observaciones?.trim()),
            estado: const Value('borrador'),
          ),
        );
      }

      final registeredItems = <PurchaseItem>[];
      for (final item in invoice.items) {
        final detalleId = await _db.into(_db.detallesCompraTable).insert(
              DetallesCompraTableCompanion.insert(
                compraId: compraId,
                presentacionId: item.presentacionId,
                lote: item.lote.trim().toUpperCase(),
                fechaVencimiento: item.fechaVencimiento,
                cantidadCajas: Value(item.cantidadCajas),
                cantidadUnidades: Value(item.cantidadUnidades),
                costoCaja: Value(item.costoCaja),
                costoUnitario: Value(item.costoUnitario),
                subtotal: Value(item.subtotal),
                cumpleRegistroSanitario: Value(item.cumpleRegistroSanitario),
                cumpleEmpaque: Value(item.cumpleEmpaque),
                temperaturaRecepcion: Value(item.temperaturaRecepcion),
              ),
            );
         registeredItems.add(item.copyWith(id: detalleId, compraId: compraId));
      }
      return invoice.copyWith(id: compraId, items: registeredItems);
    });
  }

  @override
  Future<List<PurchaseInvoice>> getPendingPurchases() async {
    final query = _db.select(_db.comprasTable).join([
      innerJoin(_db.proveedoresTable, _db.proveedoresTable.id.equalsExp(_db.comprasTable.proveedorId)),
    ])..where(_db.comprasTable.estado.isIn(['borrador', 'observada']));
    
    query.orderBy([OrderingTerm.desc(_db.comprasTable.id)]);
    
    final rows = await query.get();
    
    final List<PurchaseInvoice> results = [];
    for (var row in rows) {
       final compra = row.readTable(_db.comprasTable);
       final fullInvoice = await getPurchaseById(compra.id);
       if (fullInvoice != null) {
          results.add(fullInvoice);
       }
    }
    return results;
  }

  @override
  Future<void> deleteDraft(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.detallesCompraTable)..where((tbl) => tbl.compraId.equals(id))).go();
      await (_db.delete(_db.comprasTable)..where((tbl) => tbl.id.equals(id))).go();
    });
  }
}

/// Proveedor Riverpod para inyección del repositorio de compras (SOLID: DIP)
final purchaseRepositoryProvider = Provider<IPurchaseRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftPurchaseRepository(db);
});
