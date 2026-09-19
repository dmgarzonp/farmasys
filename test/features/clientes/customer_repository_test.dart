import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/clientes/data/repositories/drift_customer_repository.dart';
import 'package:farmsys/features/clientes/domain/entities/customer.dart';
import 'package:farmsys/features/clientes/domain/repositories/i_customer_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  late AppDatabase database;
  late ICustomerRepository customerRepo;

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
    customerRepo = DriftCustomerRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftCustomerRepository - Directorio de Clientes (SOLID: DIP)', () {
    test('Obtiene el Consumidor Final predeterminado', () async {
      final cf = await customerRepo.getConsumidorFinal();

      expect(cf.documento, equals('9999999999999'));
      expect(cf.nombreCompleto, equals('CONSUMIDOR FINAL'));
      expect(cf.isConsumidorFinal, isTrue);
    });

    test('Guarda y busca un cliente por documento o nombre', () async {
      const newCustomer = Customer(
        documento: '1712345678',
        nombreCompleto: 'JUAN PEREZ ANDRADE',
        telefono: '0991234567',
        email: 'juan.perez@example.com',
        direccion: 'Av. Amazonas y Colón',
      );

      final id = await customerRepo.saveCustomer(newCustomer);
      expect(id, greaterThan(0));

      // Búsqueda por documento
      final byDoc = await customerRepo.getCustomerByDocument('1712345678');
      expect(byDoc, isNotNull);
      expect(byDoc!.nombreCompleto, equals('JUAN PEREZ ANDRADE'));

      // Búsqueda parcial
      final searchList = await customerRepo.searchCustomers('Perez');
      expect(searchList.length, equals(1));
      expect(searchList.first.documento, equals('1712345678'));
    });
  });
}
