import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';

/// Implementación concreta de IProductRepository utilizando Drift (SQLite local).
/// Cumple con SOLID: DIP (inyectado como IProductRepository) y SRP.
class DriftProductRepository implements IProductRepository {
  final AppDatabase _db;

  DriftProductRepository(this._db);

  @override
  Future<List<Product>> searchProducts(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return getAllProducts();
    }

    final queryExpr = '%$cleanQuery%';

    final productsQuery = _db.select(_db.productosTable)
      ..where((tbl) =>
          tbl.nombreComercial.lower().like(queryExpr) |
          tbl.principioActivo.lower().like(queryExpr) |
          tbl.codigoBarras.like(queryExpr));

    final productRows = await productsQuery.get();
    return _attachPresentations(productRows);
  }

  @override
  Future<List<Product>> getAllProducts({bool onlyActive = true}) async {
    final query = _db.select(_db.productosTable);
    if (onlyActive) {
      query.where((tbl) => tbl.estado.equals('activo'));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.nombreComercial)]);

    final productRows = await query.get();
    return _attachPresentations(productRows);
  }

  @override
  Stream<List<Product>> watchAllProducts({bool onlyActive = true}) {
    final query = _db.select(_db.productosTable);
    if (onlyActive) {
      query.where((tbl) => tbl.estado.equals('activo'));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.nombreComercial)]);

    return query.watch().asyncMap(_attachPresentations);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final cleanCode = barcode.trim();
    if (cleanCode.isEmpty) return null;

    // 1. Buscar en código de barras del producto principal
    final productQuery = _db.select(_db.productosTable)
      ..where((tbl) => tbl.codigoBarras.equals(cleanCode));
    final productRow = await productQuery.getSingleOrNull();

    if (productRow != null) {
      final presentations = await _getPresentationsFor(productRow.id);
      return _toEntity(productRow, presentations);
    }

    // 2. Buscar en código de barras de las presentaciones
    final presentationQuery = _db.select(_db.presentacionesTable)
      ..where((tbl) => tbl.codigoBarras.equals(cleanCode));
    final presRow = await presentationQuery.getSingleOrNull();

    if (presRow != null) {
      final parentProductQuery = _db.select(_db.productosTable)
        ..where((tbl) => tbl.id.equals(presRow.productoId));
      final parentProduct = await parentProductQuery.getSingleOrNull();
      if (parentProduct != null) {
        final presentations = await _getPresentationsFor(parentProduct.id);
        return _toEntity(parentProduct, presentations);
      }
    }

    return null;
  }

  @override
  Future<Product?> getProductById(int id) async {
    final query = _db.select(_db.productosTable)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final presentations = await _getPresentationsFor(row.id);
    return _toEntity(row, presentations);
  }

  @override
  Future<int> saveProduct(Product product) async {
    return await _db.transaction(() async {
      int productId;

      if (product.id == null || product.id == 0) {
        // Inserción de nuevo producto
        productId = await _db.into(_db.productosTable).insert(
              ProductosTableCompanion.insert(
                nombreComercial: product.nombreComercial,
                codigoBarras: Value(product.codigoBarras),
                principioActivo: Value(product.principioActivo),
                concentracion: Value(product.concentracion),
                laboratorioId: Value(product.laboratorioId),
                categoriaId: Value(product.categoriaId),
                requiereReceta: Value(product.requiereReceta),
                esPsicotropico: Value(product.esPsicotropico),
                esAntibiotico: Value(product.esAntibiotico),
                estado: Value(product.estado),
                createdAt: Value(DateTime.now()),
              ),
            );
      } else {
        // Actualización de producto existente
        productId = product.id!;
        await (_db.update(_db.productosTable)..where((tbl) => tbl.id.equals(productId))).write(
          ProductosTableCompanion(
            nombreComercial: Value(product.nombreComercial),
            codigoBarras: Value(product.codigoBarras),
            principioActivo: Value(product.principioActivo),
            concentracion: Value(product.concentracion),
            laboratorioId: Value(product.laboratorioId),
            categoriaId: Value(product.categoriaId),
            requiereReceta: Value(product.requiereReceta),
            esPsicotropico: Value(product.esPsicotropico),
            esAntibiotico: Value(product.esAntibiotico),
            estado: Value(product.estado),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // Guardar o actualizar presentaciones vinculadas
      for (final pres in product.presentaciones) {
        if (pres.id == null || pres.id == 0) {
          await _db.into(_db.presentacionesTable).insert(
                PresentacionesTableCompanion.insert(
                  productoId: productId,
                  nombreDescriptivo: pres.nombreDescriptivo,
                  unidadesPorCaja: Value(pres.unidadesPorCaja),
                  precioCompraCaja: Value(pres.precioCompraCaja),
                  precioVentaCaja: Value(pres.precioVentaCaja),
                  precioVentaFraccion: Value(pres.precioVentaFraccion),
                  stockMinimo: Value(pres.stockMinimo),
                  codigoBarras: Value(pres.codigoBarras),
                  tieneIva: Value(pres.tieneIva),
                ),
              );
        } else {
          await (_db.update(_db.presentacionesTable)..where((tbl) => tbl.id.equals(pres.id!))).write(
            PresentacionesTableCompanion(
              nombreDescriptivo: Value(pres.nombreDescriptivo),
              unidadesPorCaja: Value(pres.unidadesPorCaja),
              precioCompraCaja: Value(pres.precioCompraCaja),
              precioVentaCaja: Value(pres.precioVentaCaja),
              precioVentaFraccion: Value(pres.precioVentaFraccion),
              stockMinimo: Value(pres.stockMinimo),
              codigoBarras: Value(pres.codigoBarras),
              tieneIva: Value(pres.tieneIva),
            ),
          );
        }
      }

      return productId;
    });
  }

  @override
  Future<void> toggleProductStatus(int id, bool isActive) async {
    await (_db.update(_db.productosTable)..where((tbl) => tbl.id.equals(id))).write(
      ProductosTableCompanion(
        estado: Value(isActive ? 'activo' : 'inactivo'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deletePresentation(int presentationId) async {
    await (_db.delete(_db.presentacionesTable)..where((tbl) => tbl.id.equals(presentationId))).go();
  }

  // --- Mapeadores y Métodos Auxiliares Privados ---

  Future<List<Product>> _attachPresentations(List<ProductosTableData> productRows) async {
    if (productRows.isEmpty) return [];

    final productIds = productRows.map((p) => p.id).toList();
    final presQuery = _db.select(_db.presentacionesTable)
      ..where((tbl) => tbl.productoId.isIn(productIds));
    final presRows = await presQuery.get();

    final Map<int, List<ProductPresentation>> presentationsByProduct = {};
    for (final presRow in presRows) {
      final list = presentationsByProduct.putIfAbsent(presRow.productoId, () => []);
      list.add(_toPresentationEntity(presRow));
    }

    return productRows.map((row) {
      final presentations = presentationsByProduct[row.id] ?? [];
      return _toEntity(row, presentations);
    }).toList();
  }

  Future<List<ProductPresentation>> _getPresentationsFor(int productId) async {
    final query = _db.select(_db.presentacionesTable)
      ..where((tbl) => tbl.productoId.equals(productId));
    final rows = await query.get();
    return rows.map(_toPresentationEntity).toList();
  }

  Product _toEntity(ProductosTableData row, List<ProductPresentation> presentations) {
    return Product(
      id: row.id,
      codigoBarras: row.codigoBarras,
      nombreComercial: row.nombreComercial,
      principioActivo: row.principioActivo,
      concentracion: row.concentracion,
      laboratorioId: row.laboratorioId,
      categoriaId: row.categoriaId,
      requiereReceta: row.requiereReceta,
      esPsicotropico: row.esPsicotropico,
      esAntibiotico: row.esAntibiotico,
      estado: row.estado,
      presentaciones: presentations,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ProductPresentation _toPresentationEntity(PresentacionesTableData row) {
    return ProductPresentation(
      id: row.id,
      productoId: row.productoId,
      nombreDescriptivo: row.nombreDescriptivo,
      unidadesPorCaja: row.unidadesPorCaja,
      precioCompraCaja: row.precioCompraCaja,
      precioVentaCaja: row.precioVentaCaja,
      precioVentaFraccion: row.precioVentaFraccion,
      stockMinimo: row.stockMinimo,
      codigoBarras: row.codigoBarras,
      tieneIva: row.tieneIva,
    );
  }
}

/// Proveedor Riverpod inyectando IProductRepository (SOLID: DIP)
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftProductRepository(db);
});
