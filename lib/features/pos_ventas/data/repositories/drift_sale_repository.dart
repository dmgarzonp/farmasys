import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../caja/data/repositories/drift_cash_session_repository.dart';
import '../../../caja/domain/repositories/i_cash_session_repository.dart';
import '../../../inventario/data/repositories/drift_inventory_repository.dart';
import '../../../inventario/domain/repositories/i_inventory_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_detail.dart';
import '../../domain/repositories/i_sale_repository.dart';

/// Implementación desacoplada del repositorio de ventas con Drift (SQLite) (SOLID: DIP/SRP)
class DriftSaleRepository implements ISaleRepository {
  final AppDatabase _db;
  final IInventoryRepository _inventoryRepo;
  final ICashSessionRepository _cashRepo;

  DriftSaleRepository(this._db, this._inventoryRepo, this._cashRepo);

  @override
  Future<Sale> processSale({
    required Sale saleHeader,
    required List<CartItem> cartItems,
  }) async {
    return await _db.transaction(() async {
      // 1. Clave de acceso fija / representativa para esta fase
      final now = DateTime.now();
      final fixedAccessKey = '001-001-${now.millisecondsSinceEpoch.toString().padLeft(9, '0')}';

      // 2. Insertar encabezado de la venta en VentasTable
      final ventaId = await _db.into(_db.ventasTable).insert(
            VentasTableCompanion.insert(
              clienteId: Value(saleHeader.clienteId),
              usuarioId: saleHeader.usuarioId,
              sesionCajaId: saleHeader.sesionCajaId,
              fechaVenta: Value(saleHeader.fechaVenta),
              subtotal0: Value(saleHeader.subtotal0),
              subtotal15: Value(saleHeader.subtotal12), // Almacena el subtotal gravado con IVA
              descuentoTotal: Value(saleHeader.descuentoTotal),
              impuestoTotal: Value(saleHeader.impuestoTotal),
              total: saleHeader.total,
              metodoPago: Value(saleHeader.metodoPago),
              claveAcceso: Value(saleHeader.claveAcceso ?? fixedAccessKey),
              estadoSri: const Value('autorizado'),
            ),
          );

      final List<SaleDetail> insertedDetails = [];

      // 3. Despacho secuencial de lotes FEFO para cada ítem del carrito
      for (final item in cartItems) {
        final allocations = await _inventoryRepo.allocateFefoStock(
          item.presentacionId,
          item.quantity,
          documentoReferencia: 'FAC-$ventaId',
        );

        for (final alloc in allocations) {
          final allocSubtotal = (alloc.quantityDeducted * item.unitPrice) - item.discount;
          final allocIva = item.hasIva ? (allocSubtotal * AppConstants.ivaVigente) : 0.0;

          final detailId = await _db.into(_db.detallesVentaTable).insert(
                DetallesVentaTableCompanion.insert(
                  ventaId: ventaId,
                  presentacionId: item.presentacionId,
                  loteId: alloc.lot.id,
                  cantidad: alloc.quantityDeducted,
                  esFraccion: Value(item.isFraccion),
                  precioUnitario: item.unitPrice,
                  descuento: Value(item.discount),
                  subtotal: allocSubtotal,
                  ivaTotal: Value(allocIva),
                ),
              );

          insertedDetails.add(
            SaleDetail(
              id: detailId,
              ventaId: ventaId,
              presentacionId: item.presentacionId,
              loteId: alloc.lot.id,
              loteCodigo: alloc.lot.lotNumber,
              productoNombre: item.productoNombre,
              presentacionNombre: item.presentacionNombre,
              cantidad: alloc.quantityDeducted,
              esFraccion: item.isFraccion,
              precioUnitario: item.unitPrice,
              descuento: item.discount,
              subtotal: allocSubtotal,
              ivaTotal: allocIva,
            ),
          );
        }
      }

      // 4. Si el pago fue en efectivo, sumar al monto esperado de la caja abierta
      if (saleHeader.metodoPago == 'efectivo') {
        await _cashRepo.addCashSale(saleHeader.sesionCajaId, saleHeader.total);
      }

      return saleHeader.copyWith(
        id: ventaId,
        claveAcceso: fixedAccessKey,
        detalles: insertedDetails,
      );
    });
  }

  @override
  Future<Sale?> getSaleById(int saleId) async {
    final query = _db.select(_db.ventasTable).join([
      leftOuterJoin(
        _db.clientesTable,
        _db.clientesTable.id.equalsExp(_db.ventasTable.clienteId),
      ),
    ])..where(_db.ventasTable.id.equals(saleId));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final v = row.readTable(_db.ventasTable);
    final c = row.readTableOrNull(_db.clientesTable);

    // Obtener detalles
    final detailsQuery = _db.select(_db.detallesVentaTable).join([
      innerJoin(
        _db.lotesTable,
        _db.lotesTable.id.equalsExp(_db.detallesVentaTable.loteId),
      ),
      innerJoin(
        _db.presentacionesTable,
        _db.presentacionesTable.id.equalsExp(_db.detallesVentaTable.presentacionId),
      ),
      innerJoin(
        _db.productosTable,
        _db.productosTable.id.equalsExp(_db.presentacionesTable.productoId),
      ),
    ])..where(_db.detallesVentaTable.ventaId.equals(saleId));

    final detailRows = await detailsQuery.get();
    final details = detailRows.map((dRow) {
      final d = dRow.readTable(_db.detallesVentaTable);
      final l = dRow.readTable(_db.lotesTable);
      final pres = dRow.readTable(_db.presentacionesTable);
      final prod = dRow.readTable(_db.productosTable);

      return SaleDetail(
        id: d.id,
        ventaId: d.ventaId,
        presentacionId: d.presentacionId,
        loteId: d.loteId,
        loteCodigo: l.lote,
        productoNombre: prod.nombreComercial,
        presentacionNombre: pres.nombreDescriptivo,
        cantidad: d.cantidad,
        esFraccion: d.esFraccion,
        precioUnitario: d.precioUnitario,
        descuento: d.descuento,
        subtotal: d.subtotal,
        ivaTotal: d.ivaTotal,
      );
    }).toList();

    return Sale(
      id: v.id,
      clienteId: v.clienteId,
      clienteNombre: c?.nombreCompleto,
      clienteDocumento: c?.documento,
      usuarioId: v.usuarioId,
      sesionCajaId: v.sesionCajaId,
      fechaVenta: v.fechaVenta,
      subtotal0: v.subtotal0,
      subtotal12: v.subtotal15,
      descuentoTotal: v.descuentoTotal,
      impuestoTotal: v.impuestoTotal,
      total: v.total,
      metodoPago: v.metodoPago,
      claveAcceso: v.claveAcceso,
      estadoSri: v.estadoSri,
      mensajeSri: v.mensajeSri,
      detalles: details,
    );
  }

  @override
  Future<List<Sale>> getRecentSales({int limit = 50}) async {
    final query = _db.select(_db.ventasTable).join([
      leftOuterJoin(
        _db.clientesTable,
        _db.clientesTable.id.equalsExp(_db.ventasTable.clienteId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(_db.ventasTable.fechaVenta)])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      final v = row.readTable(_db.ventasTable);
      final c = row.readTableOrNull(_db.clientesTable);

      return Sale(
        id: v.id,
        clienteId: v.clienteId,
        clienteNombre: c?.nombreCompleto,
        clienteDocumento: c?.documento,
        usuarioId: v.usuarioId,
        sesionCajaId: v.sesionCajaId,
        fechaVenta: v.fechaVenta,
        subtotal0: v.subtotal0,
        subtotal12: v.subtotal15,
        descuentoTotal: v.descuentoTotal,
        impuestoTotal: v.impuestoTotal,
        total: v.total,
        metodoPago: v.metodoPago,
        claveAcceso: v.claveAcceso,
        estadoSri: v.estadoSri,
        mensajeSri: v.mensajeSri,
      );
    }).toList();
  }
}

/// Proveedor Riverpod para ISaleRepository
final saleRepositoryProvider = Provider<ISaleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  final cashRepo = ref.watch(cashSessionRepositoryProvider);
  return DriftSaleRepository(db, inventoryRepo, cashRepo);
});
