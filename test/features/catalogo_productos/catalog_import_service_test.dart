import 'package:drift/native.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/catalogo_productos/domain/services/catalog_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('CatalogImportService - Generación y Detección de Plantilla', () {
    test('generateTemplateCsv genera cabeceras oficiales y filas de muestra válidas', () {
      final csv = CatalogImportService.generateTemplateCsv();

      expect(csv.contains('CODIGO_BARRAS;NOMBRE_COMERCIAL'), isTrue);
      expect(csv.contains('PARACETAMOL 500 MG'), isTrue);
      expect(csv.contains('AMOXICILINA 500 MG'), isTrue);
    });

    test('detectDelimiter detecta punto y coma, comas y tabulaciones', () {
      expect(CatalogImportService.detectDelimiter('COD;NOMBRE;PVP'), equals(';'));
      expect(CatalogImportService.detectDelimiter('COD,NOMBRE,PVP'), equals(','));
      expect(CatalogImportService.detectDelimiter('COD\tNOMBRE\tPVP'), equals('\t'));
    });
  });

  group('CatalogImportService - Parseo y Validaciones', () {
    test('parseAndValidateCsv procesa correctamente filas con delimitador punto y coma', () {
      const csvData = '''
CODIGO_BARRAS;NOMBRE_COMERCIAL;PRINCIPIO_ACTIVO;CONCENTRACION;PRESENTACION;UNIDADES_CAJA;COSTO_CAJA;PVP_CAJA;TIENE_IVA;LOTE;FECHA_VENCIMIENTO;STOCK_INICIAL;UBICACION;REQUIERE_RECETA;PSICOTROPICO;ANTIBIOTICO
7861001;PARACETAMOL;Paracetamol;500 mg;Caja x 20;20;1.50;3.00;NO;L-01;2028-12-31;10;Estante A;NO;NO;NO
''';

      final rows = CatalogImportService.parseAndValidateCsv(csvData);

      expect(rows.length, equals(1));
      final r = rows.first;
      expect(r.codigoBarras, equals('7861001'));
      expect(r.nombreComercial, equals('PARACETAMOL'));
      expect(r.unidadesPorCaja, equals(20));
      expect(r.costoCaja, equals(1.50));
      expect(r.precioVentaCaja, equals(3.00));
      expect(r.precioVentaFraccion, equals(0.15));
      expect(r.tieneIva, isFalse);
      expect(r.lote, equals('L-01'));
      expect(r.stockInicial, equals(10.0));
      expect(r.isValid, isTrue);
      expect(r.errors, isEmpty);
    });

    test('parseAndValidateCsv maneja comas decimales y formatos de fecha DD/MM/AAAA', () {
      const csvData = '''
CODIGO_BARRAS;NOMBRE_COMERCIAL;PVP_CAJA;FECHA_VENCIMIENTO;STOCK_INICIAL
7861002;IBUPROFENO;4,50;25/11/2027;15
''';

      final rows = CatalogImportService.parseAndValidateCsv(csvData);

      expect(rows.length, equals(1));
      final r = rows.first;
      expect(r.precioVentaCaja, equals(4.50));
      expect(r.fechaVencimiento, equals(DateTime(2027, 11, 25)));
      expect(r.stockInicial, equals(15.0));
      expect(r.isValid, isTrue);
    });

    test('parseAndValidateCsv detecta errores de validación de negocio', () {
      const csvData = '''
CODIGO_BARRAS;NOMBRE_COMERCIAL;PVP_CAJA;STOCK_INICIAL;FECHA_VENCIMIENTO
; ;0.00;10;
7861003;MEDICAMENTO INVALIDO;-5.00;5;2020-01-01
''';

      final rows = CatalogImportService.parseAndValidateCsv(csvData);

      expect(rows.length, equals(2));
      final r1 = rows[0];
      expect(r1.isValid, isFalse);
      expect(r1.errors.any((e) => e.contains('nombre comercial es obligatorio')), isTrue);
      expect(r1.errors.any((e) => e.contains('PVP')), isTrue);

      final r2 = rows[1];
      expect(r2.isValid, isFalse);
      expect(r2.errors.any((e) => e.contains('ya caducó')), isTrue);
    });

    test('parseAndValidateCsv remueve BOM UTF-8 automáticamente', () {
      const csvDataWithBom = '\uFEFFCODIGO_BARRAS;NOMBRE_COMERCIAL;PVP_CAJA\n786;ASPIRINA;1.50';

      final rows = CatalogImportService.parseAndValidateCsv(csvDataWithBom);

      expect(rows.length, equals(1));
      expect(rows.first.nombreComercial, equals('ASPIRINA'));
      expect(rows.first.isValid, isTrue);
    });
  });

  group('CatalogImportService - Inserción en Base de Datos (Transacción Drift)', () {
    test('executeImport inserta productos, presentaciones, lotes y registra auditoría en Kardex', () async {
      const csvData = '''
CODIGO_BARRAS;NOMBRE_COMERCIAL;PRINCIPIO_ACTIVO;CONCENTRACION;PRESENTACION;UNIDADES_CAJA;COSTO_CAJA;PVP_CAJA;TIENE_IVA;LOTE;FECHA_VENCIMIENTO;STOCK_INICIAL;UBICACION;REQUIERE_RECETA;PSICOTROPICO;ANTIBIOTICO
786000001;AMOXICILINA 500 MG;Amoxicilina;500 mg;Caja x 50;50;3.00;6.50;NO;L-AMX-01;2028-10-31;25;Estante B;SI;NO;SI
786000002;VITAMINA C 1000 MG;Ácido Ascórbico;1000 mg;Tubo x 10;10;1.20;2.80;SI;L-VIT-99;2029-05-15;50;Estante C;NO;NO;NO
''';

      final rows = CatalogImportService.parseAndValidateCsv(csvData);
      expect(rows.length, equals(2));

      final summary = await CatalogImportService.executeImport(
        rows: rows,
        db: db,
        skipInvalid: true,
      );

      expect(summary.totalRows, equals(2));
      expect(summary.validRows, equals(2));
      expect(summary.errorRows, equals(0));
      expect(summary.productsCreated, equals(2));
      expect(summary.batchesCreated, equals(2));

      // Verificar existencia en SQLite
      final allProducts = await db.select(db.productosTable).get();
      expect(allProducts.any((p) => p.nombreComercial == 'AMOXICILINA 500 MG'), isTrue);
      expect(allProducts.any((p) => p.nombreComercial == 'VITAMINA C 1000 MG'), isTrue);

      // Verificar presentaciones
      final allPresentations = await db.select(db.presentacionesTable).get();
      final amxPres = allPresentations.firstWhere((p) => p.nombreDescriptivo == 'Caja x 50');
      expect(amxPres.precioVentaCaja, equals(6.50));
      expect(amxPres.unidadesPorCaja, equals(50));

      // Verificar lotes físicos
      final allBatches = await db.select(db.lotesTable).get();
      final amxBatch = allBatches.firstWhere((b) => b.lote == 'L-AMX-01');
      expect(amxBatch.stockActual, equals(25.0));

      // Verificar Kardex (MovimientosStock)
      final allMovements = await db.select(db.movimientosStockTable).get();
      expect(allMovements.any((m) => m.documentoReferencia == 'CARGA_INICIAL'), isTrue);
    });

    test('executeImport actualiza productos existentes en lugar de duplicarlos', () async {
      const csvInitial = '''
CODIGO_BARRAS;NOMBRE_COMERCIAL;PVP_CAJA
786999;CLONAZEPAM 2 MG;5.00
''';
      final initialRows = CatalogImportService.parseAndValidateCsv(csvInitial);
      await CatalogImportService.executeImport(rows: initialRows, db: db);

      // Re-importar con nuevo precio y principio activo
      const csvUpdate = '''
CODIGO_BARRAS;NOMBRE_COMERCIAL;PRINCIPIO_ACTIVO;PVP_CAJA;PSICOTROPICO
786999;CLONAZEPAM 2 MG;Clonazepam;6.20;SI
''';
      final updateRows = CatalogImportService.parseAndValidateCsv(csvUpdate);
      final updateSummary = await CatalogImportService.executeImport(rows: updateRows, db: db);

      expect(updateSummary.productsCreated, equals(0));
      expect(updateSummary.productsUpdated, equals(1));

      final product = await (db.select(db.productosTable)
            ..where((tbl) => tbl.codigoBarras.equals('786999')))
          .getSingle();
      expect(product.principioActivo, equals('Clonazepam'));
      expect(product.esPsicotropico, isTrue);

      final pres = await (db.select(db.presentacionesTable)
            ..where((tbl) => tbl.productoId.equals(product.id)))
          .getSingle();
      expect(pres.precioVentaCaja, equals(6.20));
    });
  });
}
