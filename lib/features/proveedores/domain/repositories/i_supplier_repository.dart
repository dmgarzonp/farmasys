import '../entities/supplier.dart';

/// Contrato abstracto para el repositorio de proveedores (SOLID: DIP)
abstract class ISupplierRepository {
  /// Retorna todos los proveedores registrados
  Future<List<Supplier>> getSuppliers({bool activeOnly = false});

  /// Obtiene un proveedor por su ID primario
  Future<Supplier?> getSupplierById(int id);

  /// Obtiene un proveedor por su RUC de 13 dígitos
  Future<Supplier?> getSupplierByRuc(String ruc);

  /// Registra un nuevo proveedor y retorna su ID generado
  Future<int> saveSupplier(Supplier supplier);

  /// Actualiza los datos de un proveedor existente
  Future<bool> updateSupplier(Supplier supplier);

  /// Busca proveedores por RUC, nombre de empresa o contacto
  Future<List<Supplier>> searchSuppliers(String query);
}
