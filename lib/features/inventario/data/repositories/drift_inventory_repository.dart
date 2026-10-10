import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/fefo_comparator.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/batch_stock.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/i_inventory_repository.dart';

/// Implementación desacoplada del repositorio de inventario con Drift (SQLite).
/// Cumple con los principios SOLID: DIP, ISP y SRP.
class DriftInventoryRepository implements IInventoryRepository {
  final AppDatabase _db;

  DriftInventoryRepository(this._db);

  @override
  Future<List<BatchStock>> getAllBatches({
    bool onlyWithStock = false,
    bool onlyExpiringSoon = false,
    bool onlyExpired = false,
  }) async {
    final query = _buildBatchQuery(
      onlyWithStock: onlyWithStock,
      onlyExpiringSoon: onlyExpiringSoon,
      onlyExpired: onlyExpired,
    );

    final rows = await query.get();
    return rows.map(_mapRowToBatch).toList();
  }

  @override
  Stream<List<BatchStock>> watchAllBatches() {
    final query = _buildBatchQuery();
    query.limit(300); // OPTIMIZACIÓN: Límite para evitar sobrecarga en Desktop
    return query.watch().map((rows) => rows.map(_mapRowToBatch).toList());
  }

  @override
  Stream<Map<int, double>> watchAvailableStockMap() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Unix timestamp conversion for SQLite date comparison, or we can just rely on Drift's date serialization
    final todaySeconds = (today.millisecondsSinceEpoch / 1000).floor();

    final query = _db.customSelect(
      'SELECT presentacion_id, SUM(stock_actual) as total '
      'FROM lotes '
      'WHERE stock_actual > 0 AND fecha_vencimiento >= ? '
      'GROUP BY presentacion_id',
      variables: [Variable.withInt(todaySeconds)], // Drift uses unix timestamps internally
      readsFrom: {_db.lotesTable},
    );

    return query.watch().map((rows) {
      final map = <int, double>{};
      for (final row in rows) {
        final presId = row.read<int>('presentacion_id');
        final total = row.read<double>('total');
        map[presId] = total;
      }
      return map;
    });
  }

  @override
  Future<PaginatedResult<BatchStock>> getBatchesPaginated({
    required int limit,
    required int offset,
    String? query,
    bool onlyWithStock = false,
    bool onlyExpiringSoon = false,
    bool onlyExpired = false,
  }) async {
    final batchQuery = _buildBatchQuery(
      onlyWithStock: onlyWithStock,
      onlyExpiringSoon: onlyExpiringSoon,
      onlyExpired: onlyExpired,
    );

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.trim().toLowerCase();
      final queryExpr = '%$cleanQuery%';
      batchQuery.where(
          _db.productosTable.nombreComercial.lower().like(queryExpr) |
          _db.lotesTable.lote.lower().like(queryExpr) |
          _db.productosTable.codigoBarras.like(queryExpr));
    }

    // Count
    final countQuery = _buildBatchQuery(
      onlyWithStock: onlyWithStock,
      onlyExpiringSoon: onlyExpiringSoon,
      onlyExpired: onlyExpired,
    );

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.trim().toLowerCase();
      final queryExpr = '%$cleanQuery%';
      countQuery.where(
          _db.productosTable.nombreComercial.lower().like(queryExpr) |
          _db.lotesTable.lote.lower().like(queryExpr) |
          _db.productosTable.codigoBarras.like(queryExpr));
    }

    final countExp = _db.lotesTable.id.count();
    countQuery.addColumns([countExp]);
    final countResult = await countQuery.getSingle();
    final totalCount = countResult.read(countExp) ?? 0;

    batchQuery.limit(limit, offset: offset);
    final rows = await batchQuery.get();
    final items = rows.map(_mapRowToBatch).toList();

    return PaginatedResult<BatchStock>(
      items: items,
      totalCount: totalCount,
    );
  }

  @override
  Future<BatchStock?> getBatchById(int id) async {
    final query = _buildBatchQuery()..where(_db.lotesTable.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _mapRowToBatch(row) : null;
  }

  @override
  Future<List<BatchStock>> getBatchesForPresentation(int presentacionId) async {
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
      ..where(_db.lotesTable.presentacionId.equals(presentacionId))
      ..orderBy([OrderingTerm.asc(_db.lotesTable.fechaVencimiento)]);

    final rows = await query.get();
    return rows.map(_mapRowToBatch).toList();
  }

  @override
  Future<int> registerBatchEntry(
    BatchStock batch, {
    String? documentoReferencia,
    String? observaciones,
  }) async {
    return await _db.transaction(() async {
      // 1. Insertar el nuevo lote físico
      final loteId = await _db.into(_db.lotesTable).insert(
            LotesTableCompanion.insert(
              presentacionId: batch.presentacionId,
              lote: batch.lote.trim().toUpperCase(),
              fechaVencimiento: batch.fechaVencimiento,
              fechaIngreso: Value(batch.fechaIngreso),
              stockActual: Value(batch.stockActual),
              precioCompraCaja: Value(batch.precioCompraCaja),
              precioCompraUnitario: Value(batch.precioCompraUnitario),
              ubicacion: Value(batch.ubicacion),
            ),
          );

      // 2. Registrar movimiento de auditoría en Kardex
      await _db.into(_db.movimientosStockTable).insert(
            MovimientosStockTableCompanion.insert(
              tipo: 'entrada_compra',
              loteId: loteId,
              cantidad: batch.stockActual,
              documentoReferencia: Value(documentoReferencia),
              fechaMovimiento: Value(DateTime.now()),
              observaciones: Value(observaciones ?? 'Ingreso inicial de mercadería'),
            ),
          );

      return loteId;
    });
  }

  @override
  Future<List<LotAllocation>> allocateFefoStock(
    int presentacionId,
    double requestedQuantity, {
    String? documentoReferencia,
  }) async {
    return await _db.transaction(() async {
      // 1. Obtener lotes disponibles ordenados por vencimiento (FEFO)
      final batches = await getBatchesForPresentation(presentacionId);

      final lotItems = batches
          .map((b) => LotItem(
                id: b.id!,
                lotNumber: b.lote,
                expirationDate: b.fechaVencimiento,
                entryDate: b.fechaIngreso,
                currentStock: b.stockActual,
                unitCost: b.precioCompraUnitario,
              ))
          .toList();

      // 2. Ejecutar motor de cálculo FEFO centralizado (DRY)
      final allocations = FefoComparator.allocateStock(
        lots: lotItems,
        requestedQuantity: requestedQuantity,
      );

      // 3. Aplicar descuento de stock y registrar movimientos Kardex
      for (final alloc in allocations) {
        final newStock = alloc.lot.currentStock - alloc.quantityDeducted;

        await (_db.update(_db.lotesTable)..where((tbl) => tbl.id.equals(alloc.lot.id))).write(
          LotesTableCompanion(stockActual: Value(newStock)),
        );

        await _db.into(_db.movimientosStockTable).insert(
              MovimientosStockTableCompanion.insert(
                tipo: 'salida_venta',
                loteId: alloc.lot.id,
                cantidad: alloc.quantityDeducted,
                documentoReferencia: Value(documentoReferencia),
                fechaMovimiento: Value(DateTime.now()),
                observaciones: const Value('Despacho automático FEFO'),
              ),
            );
      }

      return allocations;
    });
  }

  @override
  Future<void> adjustStock(int batchId, double newStock, String motivo) async {
    await _db.transaction(() async {
      final lotRow = await (_db.select(_db.lotesTable)..where((tbl) => tbl.id.equals(batchId)))
          .getSingleOrNull();
      if (lotRow == null) throw StateError('Lote no encontrado para ajuste.');

      final diff = newStock - lotRow.stockActual;
      if (diff == 0) return;

      await (_db.update(_db.lotesTable)..where((tbl) => tbl.id.equals(batchId))).write(
        LotesTableCompanion(stockActual: Value(newStock)),
      );

      await _db.into(_db.movimientosStockTable).insert(
            MovimientosStockTableCompanion.insert(
              tipo: diff > 0 ? 'ajuste_positivo' : 'ajuste_negativo',
              loteId: batchId,
              cantidad: diff.abs(),
              fechaMovimiento: Value(DateTime.now()),
              observaciones: Value(motivo),
            ),
          );
    });
  }

  @override
  Future<void> registerBatchExit(
    int batchId,
    double quantity,
    String reasonType, {
    int? supplierId,
    String? referenceDocument,
    String? observations,
  }) async {
    await _db.transaction(() async {
      // 1. Obtener lote
      final lotRow = await (_db.select(_db.lotesTable)..where((tbl) => tbl.id.equals(batchId))).getSingleOrNull();
      if (lotRow == null) throw StateError('Lote no encontrado.');

      // 2. Validar cantidad
      if (quantity > lotRow.stockActual) {
        throw StateError('La cantidad a retirar supera el stock actual del lote.');
      }

      // 3. Deducir stock
      final newStock = lotRow.stockActual - quantity;
      await (_db.update(_db.lotesTable)..where((tbl) => tbl.id.equals(batchId))).write(
        LotesTableCompanion(stockActual: Value(newStock)),
      );

      // 4. Generar movimiento
      await _db.into(_db.movimientosStockTable).insert(
            MovimientosStockTableCompanion.insert(
              tipo: reasonType,
              loteId: batchId,
              cantidad: quantity,
              documentoReferencia: Value(referenceDocument),
              fechaMovimiento: Value(DateTime.now()),
              observaciones: Value(observations),
            ),
          );

      // 5. Incrementar saldo a favor del proveedor (Si aplica)
      if (reasonType == 'devolucion_proveedor' && supplierId != null) {
        final supplierRow = await (_db.select(_db.proveedoresTable)..where((tbl) => tbl.id.equals(supplierId))).getSingleOrNull();
        if (supplierRow != null) {
          final devolucionValue = quantity * lotRow.precioCompraUnitario;
          final newBalance = supplierRow.saldoAFavor + devolucionValue;
          
          await (_db.update(_db.proveedoresTable)..where((tbl) => tbl.id.equals(supplierId))).write(
            ProveedoresTableCompanion(saldoAFavor: Value(newBalance)),
          );
        }
      }
    });
  }

  @override
  Future<List<StockMovement>> getKardexMovements({int? batchId, int limit = 100}) async {
    final query = _db.select(_db.movimientosStockTable).join([
      innerJoin(
        _db.lotesTable,
        _db.lotesTable.id.equalsExp(_db.movimientosStockTable.loteId),
      ),
      innerJoin(
        _db.presentacionesTable,
        _db.presentacionesTable.id.equalsExp(_db.lotesTable.presentacionId),
      ),
      innerJoin(
        _db.productosTable,
        _db.productosTable.id.equalsExp(_db.presentacionesTable.productoId),
      ),
    ]);

    if (batchId != null) {
      query.where(_db.movimientosStockTable.loteId.equals(batchId));
    }

    query.orderBy([OrderingTerm.desc(_db.movimientosStockTable.fechaMovimiento)]);
    query.limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      final m = row.readTable(_db.movimientosStockTable);
      final l = row.readTable(_db.lotesTable);
      final p = row.readTable(_db.productosTable);

      return StockMovement(
        id: m.id,
        tipo: m.tipo,
        loteId: m.loteId,
        loteCode: l.lote,
        productName: p.nombreComercial,
        cantidad: m.cantidad,
        documentoReferencia: m.documentoReferencia,
        fechaMovimiento: m.fechaMovimiento,
        usuarioId: m.usuarioId,
        observaciones: m.observaciones,
      );
    }).toList();
  }

  // --- Métodos Auxiliares y Mapeadores Privados ---

  JoinedSelectStatement<HasResultSet, dynamic> _buildBatchQuery({
    bool onlyWithStock = false,
    bool onlyExpiringSoon = false,
    bool onlyExpired = false,
  }) {
    final query = _db.select(_db.lotesTable).join([
      innerJoin(
        _db.presentacionesTable,
        _db.presentacionesTable.id.equalsExp(_db.lotesTable.presentacionId),
      ),
      innerJoin(
        _db.productosTable,
        _db.productosTable.id.equalsExp(_db.presentacionesTable.productoId),
      ),
    ]);

    // Filtrar siempre para que no se muestren productos inactivos
    query.where(_db.productosTable.estado.equals('activo'));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final in90Days = today.add(const Duration(days: 90));

    if (onlyWithStock) {
      query.where(_db.lotesTable.stockActual.isBiggerThanValue(0.0));
    }

    if (onlyExpired) {
      query.where(_db.lotesTable.fechaVencimiento.isSmallerThanValue(today));
    } else if (onlyExpiringSoon) {
      query.where(
        _db.lotesTable.fechaVencimiento.isBiggerOrEqualValue(today) &
            _db.lotesTable.fechaVencimiento.isSmallerOrEqualValue(in90Days),
      );
    }

    query.orderBy([OrderingTerm.asc(_db.lotesTable.fechaVencimiento)]);
    return query;
  }

  BatchStock _mapRowToBatch(TypedResult row) {
    final lot = row.readTable(_db.lotesTable);
    final pres = row.readTable(_db.presentacionesTable);
    final prod = row.readTable(_db.productosTable);

    return BatchStock(
      id: lot.id,
      presentacionId: lot.presentacionId,
      productName: prod.nombreComercial,
      presentationName: pres.nombreDescriptivo,
      lote: lot.lote,
      fechaVencimiento: lot.fechaVencimiento,
      fechaIngreso: lot.fechaIngreso,
      stockActual: lot.stockActual,
      precioCompraCaja: lot.precioCompraCaja,
      precioCompraUnitario: lot.precioCompraUnitario,
      ubicacion: lot.ubicacion,
    );
  }
}

/// Proveedor Riverpod para IInventoryRepository (SOLID: DIP)
final inventoryRepositoryProvider = Provider<IInventoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftInventoryRepository(db);
});
