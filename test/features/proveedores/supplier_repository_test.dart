import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/proveedores/data/repositories/drift_supplier_repository.dart';
import 'package:farmsys/features/proveedores/domain/entities/supplier.dart';
import 'package:farmsys/features/proveedores/domain/repositories/i_supplier_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  late AppDatabase database;
  late ISupplierRepository supplierRepo;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      try {
        return DynamicLibrary.open('libsqlite3.so');
      } catch (_) {
        return DynamicLibrary.open('libsqlite3.so.0');
      }
    });
  });

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    supplierRepo = DriftSupplierRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftSupplierRepository - Gestión de Distribuidores Farmacéuticos (SOLID: DIP)', () {
    test('Guarda y obtiene un proveedor por RUC y por ID', () async {
      const newSupplier = Supplier(
        ruc: '1790016919001',
        nombreEmpresa: 'DIFARUM CÍA. LTDA.',
        direccion: 'Av. Galo Plaza Lasso y De los Eucaliptos',
        telefonoEmpresa: '022485900',
        emailEmpresa: 'pedidos@difarum.com.ec',
        nombreContacto: 'CARLOS ALMEIDA',
        telefonoContacto: '0987654321',
      );

      final id = await supplierRepo.saveSupplier(newSupplier);
      expect(id, greaterThan(0));

      // Consulta por ID
      final byId = await supplierRepo.getSupplierById(id);
      expect(byId, isNotNull);
      expect(byId!.nombreEmpresa, equals('DIFARUM CÍA. LTDA.'));
      expect(byId.ruc, equals('1790016919001'));
      expect(byId.isActive, isTrue);

      // Consulta por RUC
      final byRuc = await supplierRepo.getSupplierByRuc('1790016919001');
      expect(byRuc, isNotNull);
      expect(byRuc!.id, equals(id));
    });

    test('Busca proveedores por término en RUC, nombre o contacto', () async {
      await supplierRepo.saveSupplier(const Supplier(
        ruc: '0990004199001',
        nombreEmpresa: 'GRUPO DIFARE S.A.',
        nombreContacto: 'MARIA LOPEZ',
      ));

      await supplierRepo.saveSupplier(const Supplier(
        ruc: '1790034444001',
        nombreEmpresa: 'LETERAGO DEL ECUADOR S.A.',
        nombreContacto: 'ANDRES SALAZAR',
      ));

      // Búsqueda por nombre comercial
      final byName = await supplierRepo.searchSuppliers('Difare');
      expect(byName.length, equals(1));
      expect(byName.first.nombreEmpresa, equals('GRUPO DIFARE S.A.'));

      // Búsqueda por contacto
      final byContact = await supplierRepo.searchSuppliers('Salazar');
      expect(byContact.length, equals(1));
      expect(byContact.first.nombreEmpresa, equals('LETERAGO DEL ECUADOR S.A.'));
    });

    test('Actualiza datos de un proveedor existente', () async {
      final id = await supplierRepo.saveSupplier(const Supplier(
        ruc: '1791234567001',
        nombreEmpresa: 'PROVEEDOR TEST S.A.',
        telefonoEmpresa: '022000111',
      ));

      final original = await supplierRepo.getSupplierById(id);
      expect(original, isNotNull);

      final updated = original!.copyWith(
        telefonoEmpresa: '022999888',
        nombreContacto: 'NUEVO CONTACTO',
      );

      final ok = await supplierRepo.updateSupplier(updated);
      expect(ok, isTrue);

      final modified = await supplierRepo.getSupplierById(id);
      expect(modified!.telefonoEmpresa, equals('022999888'));
      expect(modified.nombreContacto, equals('NUEVO CONTACTO'));
    });
  });
}
