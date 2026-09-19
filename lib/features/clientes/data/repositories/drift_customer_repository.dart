import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/i_customer_repository.dart';

/// Implementación desacoplada del repositorio de clientes con Drift (SQLite)
class DriftCustomerRepository implements ICustomerRepository {
  final AppDatabase _db;

  DriftCustomerRepository(this._db);

  @override
  Future<Customer> getConsumidorFinal() async {
    final row = await (_db.select(_db.clientesTable)
          ..where((t) => t.documento.equals(AppConstants.consumidorFinalDocumento)))
        .getSingleOrNull();

    if (row != null) {
      return _mapRowToEntity(row);
    }

    // Si aún no existe en base, lo insertamos como dato maestro fijo
    final id = await _db.into(_db.clientesTable).insert(
          ClientesTableCompanion.insert(
            documento: AppConstants.consumidorFinalDocumento,
            tipoDocumento: const Value('07'),
            nombreCompleto: AppConstants.consumidorFinalNombre,
            direccion: const Value('S/D'),
          ),
        );

    return Customer.consumidorFinal(id: id);
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      final rows = await (_db.select(_db.clientesTable)
            ..orderBy([(t) => OrderingTerm.asc(t.nombreCompleto)])
            ..limit(20))
          .get();
      return rows.map(_mapRowToEntity).toList();
    }

    final rows = await (_db.select(_db.clientesTable)
          ..where((t) => t.documento.like('%$cleanQuery%') | t.nombreCompleto.like('%$cleanQuery%'))
          ..orderBy([(t) => OrderingTerm.asc(t.nombreCompleto)])
          ..limit(25))
        .get();

    return rows.map(_mapRowToEntity).toList();
  }

  @override
  Future<Customer?> getCustomerById(int id) async {
    final row = await (_db.select(_db.clientesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapRowToEntity(row);
  }

  @override
  Future<Customer?> getCustomerByDocument(String document) async {
    final row = await (_db.select(_db.clientesTable)..where((t) => t.documento.equals(document.trim()))).getSingleOrNull();
    return row == null ? null : _mapRowToEntity(row);
  }

  @override
  Future<int> saveCustomer(Customer customer) async {
    if (customer.id == null) {
      return await _db.into(_db.clientesTable).insert(
            ClientesTableCompanion.insert(
              documento: customer.documento.trim(),
              tipoDocumento: Value(customer.tipoDocumento),
              nombreCompleto: customer.nombreCompleto.trim().toUpperCase(),
              telefono: Value(customer.telefono?.trim()),
              email: Value(customer.email?.trim().toLowerCase()),
              direccion: Value(customer.direccion?.trim().toUpperCase()),
            ),
          );
    } else {
      await (_db.update(_db.clientesTable)..where((t) => t.id.equals(customer.id!))).write(
        ClientesTableCompanion(
          documento: Value(customer.documento.trim()),
          tipoDocumento: Value(customer.tipoDocumento),
          nombreCompleto: Value(customer.nombreCompleto.trim().toUpperCase()),
          telefono: Value(customer.telefono?.trim()),
          email: Value(customer.email?.trim().toLowerCase()),
          direccion: Value(customer.direccion?.trim().toUpperCase()),
        ),
      );
      return customer.id!;
    }
  }

  Customer _mapRowToEntity(ClientesTableData row) {
    return Customer(
      id: row.id,
      documento: row.documento,
      tipoDocumento: row.tipoDocumento,
      nombreCompleto: row.nombreCompleto,
      telefono: row.telefono,
      email: row.email,
      direccion: row.direccion,
    );
  }
}

/// Proveedor Riverpod para ICustomerRepository
final customerRepositoryProvider = Provider<ICustomerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftCustomerRepository(db);
});
