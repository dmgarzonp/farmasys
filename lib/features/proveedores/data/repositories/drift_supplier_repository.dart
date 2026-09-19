import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/i_supplier_repository.dart';

/// Implementación Drift para repositorio de proveedores y distribuidores farmacéuticos (SOLID: DIP)
class DriftSupplierRepository implements ISupplierRepository {
  final AppDatabase _db;

  DriftSupplierRepository(this._db);

  @override
  Future<List<Supplier>> getSuppliers({bool activeOnly = false}) async {
    final query = _db.select(_db.proveedoresTable);
    if (activeOnly) {
      query.where((t) => t.estado.equals('activo'));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.nombreEmpresa)]);

    final rows = await query.get();
    return rows.map(_mapRowToEntity).toList();
  }

  @override
  Future<Supplier?> getSupplierById(int id) async {
    final row = await (_db.select(_db.proveedoresTable)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<Supplier?> getSupplierByRuc(String ruc) async {
    final row = await (_db.select(_db.proveedoresTable)..where((t) => t.ruc.equals(ruc))).getSingleOrNull();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<int> saveSupplier(Supplier supplier) async {
    return await _db.into(_db.proveedoresTable).insert(
          ProveedoresTableCompanion.insert(
            ruc: supplier.ruc.trim(),
            nombreEmpresa: supplier.nombreEmpresa.trim().toUpperCase(),
            direccion: Value(supplier.direccion?.trim().toUpperCase()),
            telefonoEmpresa: Value(supplier.telefonoEmpresa?.trim()),
            emailEmpresa: Value(supplier.emailEmpresa?.trim().toLowerCase()),
            nombreContacto: Value(supplier.nombreContacto?.trim().toUpperCase()),
            telefonoContacto: Value(supplier.telefonoContacto?.trim()),
            emailContacto: Value(supplier.emailContacto?.trim().toLowerCase()),
            estado: Value(supplier.estado),
          ),
        );
  }

  @override
  Future<bool> updateSupplier(Supplier supplier) async {
    if (supplier.id == null) return false;

    final count = await (_db.update(_db.proveedoresTable)..where((t) => t.id.equals(supplier.id!))).write(
      ProveedoresTableCompanion(
        ruc: Value(supplier.ruc.trim()),
        nombreEmpresa: Value(supplier.nombreEmpresa.trim().toUpperCase()),
        direccion: Value(supplier.direccion?.trim().toUpperCase()),
        telefonoEmpresa: Value(supplier.telefonoEmpresa?.trim()),
        emailEmpresa: Value(supplier.emailEmpresa?.trim().toLowerCase()),
        nombreContacto: Value(supplier.nombreContacto?.trim().toUpperCase()),
        telefonoContacto: Value(supplier.telefonoContacto?.trim()),
        emailContacto: Value(supplier.emailContacto?.trim().toLowerCase()),
        estado: Value(supplier.estado),
      ),
    );
    return count > 0;
  }

  @override
  Future<List<Supplier>> searchSuppliers(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      return getSuppliers(activeOnly: true);
    }

    final rows = await (_db.select(_db.proveedoresTable)
          ..where((t) => t.ruc.like('%$clean%') | t.nombreEmpresa.like('%$clean%') | t.nombreContacto.like('%$clean%'))
          ..orderBy([(t) => OrderingTerm.asc(t.nombreEmpresa)])
          ..limit(30))
        .get();

    return rows.map(_mapRowToEntity).toList();
  }

  Supplier _mapRowToEntity(ProveedoresTableData row) {
    return Supplier(
      id: row.id,
      ruc: row.ruc,
      nombreEmpresa: row.nombreEmpresa,
      direccion: row.direccion,
      telefonoEmpresa: row.telefonoEmpresa,
      emailEmpresa: row.emailEmpresa,
      nombreContacto: row.nombreContacto,
      telefonoContacto: row.telefonoContacto,
      emailContacto: row.emailContacto,
      estado: row.estado,
      createdAt: row.createdAt,
    );
  }
}

/// Proveedor Riverpod inyectado para acceso a proveedores (SOLID: DIP)
final supplierRepositoryProvider = Provider<ISupplierRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftSupplierRepository(db);
});
