import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/catalogo_productos/data/repositories/drift_product_repository.dart';
import 'package:farmsys/features/catalogo_productos/domain/entities/product.dart';
import 'package:farmsys/features/catalogo_productos/domain/repositories/i_product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  late AppDatabase database;
  late IProductRepository repository;

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
    // Base de datos SQLite pura en memoria volátil para pruebas unitarias
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftProductRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftProductRepository - Catálogo de Medicamentos Desacoplado (SOLID: DIP)', () {
    test('Guarda un medicamento con su presentación y lo recupera por ID', () async {
      const product = Product(
        nombreComercial: 'Paracetamol 500mg MK',
        principioActivo: 'Paracetamol',
        concentracion: '500 mg',
        codigoBarras: '7861000111222',
        requiereReceta: false,
        esAntibiotico: false,
        esPsicotropico: false,
        presentaciones: [
          ProductPresentation(
            nombreDescriptivo: 'Caja x 100 tabletas',
            unidadesPorCaja: 100,
            precioCompraCaja: 4.50,
            precioVentaCaja: 8.00,
            precioVentaFraccion: 0.10,
            tieneIva: false, // 0% medicamentos humanos
          ),
        ],
      );

      final id = await repository.saveProduct(product);
      expect(id, greaterThan(0));

      final fetched = await repository.getProductById(id);
      expect(fetched, isNotNull);
      expect(fetched!.nombreComercial, equals('Paracetamol 500mg MK'));
      expect(fetched.principioActivo, equals('Paracetamol'));
      expect(fetched.presentaciones.length, equals(1));
      expect(fetched.presentaciones.first.precioVentaCaja, equals(8.00));
      expect(fetched.presentaciones.first.tieneIva, isFalse);
    });

    test('Búsqueda reactiva por nombre o principio activo', () async {
      await repository.saveProduct(const Product(
        nombreComercial: 'Amoxicilina 500mg Genfar',
        principioActivo: 'Amoxicilina',
        esAntibiotico: true,
        requiereReceta: true,
      ));

      await repository.saveProduct(const Product(
        nombreComercial: 'Ibuprofeno 400mg La Sante',
        principioActivo: 'Ibuprofeno',
        requiereReceta: false,
      ));

      // Búsqueda por parte del nombre comercial
      final resultName = await repository.searchProducts('Amoxi');
      expect(resultName.length, equals(1));
      expect(resultName.first.nombreComercial, contains('Amoxicilina'));

      // Búsqueda por principio activo
      final resultActive = await repository.searchProducts('ibuprofeno');
      expect(resultActive.length, equals(1));
      expect(resultActive.first.nombreComercial, contains('Ibuprofeno'));
    });

    test('Búsqueda por código de barras de producto o presentación', () async {
      await repository.saveProduct(const Product(
        nombreComercial: 'Aspirina 100mg Bayer',
        codigoBarras: '770200000001',
        presentaciones: [
          ProductPresentation(
            nombreDescriptivo: 'Blíster x 10',
            codigoBarras: '770200000002',
            precioVentaCaja: 1.50,
          ),
        ],
      ));

      // Buscar por código del producto padre
      final byParentBarcode = await repository.getProductByBarcode('770200000001');
      expect(byParentBarcode, isNotNull);
      expect(byParentBarcode!.nombreComercial, equals('Aspirina 100mg Bayer'));

      // Buscar por código de la presentación
      final byPresBarcode = await repository.getProductByBarcode('770200000002');
      expect(byPresBarcode, isNotNull);
      expect(byPresBarcode!.nombreComercial, equals('Aspirina 100mg Bayer'));
    });

    test('Inactivación lógica de producto (soft delete)', () async {
      final id = await repository.saveProduct(const Product(
        nombreComercial: 'Producto Temporal',
      ));

      // Por defecto está activo
      var activeList = await repository.getAllProducts(onlyActive: true);
      expect(activeList.any((p) => p.id == id), isTrue);

      // Inactivar
      await repository.toggleProductStatus(id, false);

      activeList = await repository.getAllProducts(onlyActive: true);
      expect(activeList.any((p) => p.id == id), isFalse);

      final allList = await repository.getAllProducts(onlyActive: false);
      expect(allList.any((p) => p.id == id), isTrue);
    });
  });
}
