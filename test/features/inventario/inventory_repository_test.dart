import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/catalogo_productos/data/repositories/drift_product_repository.dart';
import 'package:farmsys/features/catalogo_productos/domain/entities/product.dart';
import 'package:farmsys/features/inventario/data/repositories/drift_inventory_repository.dart';
import 'package:farmsys/features/inventario/domain/entities/batch_stock.dart';
import 'package:farmsys/features/inventario/domain/repositories/i_inventory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  late AppDatabase database;
  late IInventoryRepository inventoryRepo;
  late int presentationId;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      try {
        return DynamicLibrary.open('libsqlite3.so');
      } catch (_) {
        return DynamicLibrary.open('libsqlite3.so.0');
      }
    });
  });

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    inventoryRepo = DriftInventoryRepository(database);

    // Creamos un producto y presentación base para las pruebas de inventario
    final productRepo = DriftProductRepository(database);
    final prodId = await productRepo.saveProduct(
      const Product(
        nombreComercial: 'Amoxicilina + Ácido Clavulánico 875/125mg',
        principioActivo: 'Amoxicilina + Ácido Clavulánico',
        presentaciones: [
          ProductPresentation(
            nombreDescriptivo: 'Caja x 14 tabletas recubiertas',
            unidadesPorCaja: 14,
            precioCompraCaja: 12.00,
            precioVentaCaja: 18.50,
          ),
        ],
      ),
    );

    final product = await productRepo.getProductById(prodId);
    presentationId = product!.presentaciones.first.id!;
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftInventoryRepository - Control Trazable por Lotes, Kardex y FEFO (SOLID: DIP)', () {
    test('Registra ingreso de lote y genera movimiento Kardex entrada_compra automáticamente', () async {
      final now = DateTime.now();
      final expirationDate = DateTime(now.year + 2, now.month, now.day);

      final batch = BatchStock(
        presentacionId: presentationId,
        productName: 'Amoxicilina + Ácido Clavulánico',
        presentationName: 'Caja x 14',
        lote: 'LOTE-TEST-001',
        fechaVencimiento: expirationDate,
        fechaIngreso: now,
        stockActual: 50.0,
        precioCompraCaja: 12.00,
        precioCompraUnitario: 0.857,
        ubicacion: 'Estantería A-2',
      );

      final batchId = await inventoryRepo.registerBatchEntry(
        batch,
        documentoReferencia: 'FACT-001-002-9988',
        observaciones: 'Ingreso inicial por compra a distribuidor',
      );

      expect(batchId, greaterThan(0));

      // Verificar que el lote existe en la base de datos
      final batches = await inventoryRepo.getBatchesForPresentation(presentationId);
      expect(batches.length, equals(1));
      expect(batches.first.id, equals(batchId));
      expect(batches.first.lote, equals('LOTE-TEST-001'));
      expect(batches.first.stockActual, equals(50.0));
      expect(batches.first.ubicacion, equals('Estantería A-2'));

      // Verificar que se auditó en Kardex como entrada_compra
      final movements = await inventoryRepo.getKardexMovements(batchId: batchId);
      expect(movements.length, equals(1));
      expect(movements.first.tipo, equals('entrada_compra'));
      expect(movements.first.cantidad, equals(50.0));
      expect(movements.first.documentoReferencia, equals('FACT-001-002-9988'));
      expect(movements.first.observaciones, contains('Ingreso inicial'));
    });

    test('getBatchesForPresentation ordena estrictamente por FEFO (más próximo a caducar primero)', () async {
      final now = DateTime.now();
      // Lote 1 vence en 60 días
      final batch1 = BatchStock(
        presentacionId: presentationId,
        productName: 'Amoxicilina',
        presentationName: 'Caja x 14',
        lote: 'LOTE-PROXIMO',
        fechaVencimiento: now.add(const Duration(days: 60)),
        fechaIngreso: now,
        stockActual: 10.0,
      );

      // Lote 2 vence en 365 días
      final batch2 = BatchStock(
        presentacionId: presentationId,
        productName: 'Amoxicilina',
        presentationName: 'Caja x 14',
        lote: 'LOTE-LEJANO',
        fechaVencimiento: now.add(const Duration(days: 365)),
        fechaIngreso: now,
        stockActual: 20.0,
      );

      // Registramos en orden inverso (primero el lejano)
      await inventoryRepo.registerBatchEntry(batch2);
      await inventoryRepo.registerBatchEntry(batch1);

      final fefoBatches = await inventoryRepo.getBatchesForPresentation(presentationId);
      expect(fefoBatches.length, equals(2));
      // El primero debe ser el que vence en 60 días
      expect(fefoBatches.first.lote, equals('LOTE-PROXIMO'));
      expect(fefoBatches.last.lote, equals('LOTE-LEJANO'));
    });

    test('allocateFefoStock descuenta existencias secuencialmente y audita salida_venta en Kardex', () async {
      final now = DateTime.now();

      // Lote A: 10 unidades, vence en 30 días
      await inventoryRepo.registerBatchEntry(
        BatchStock(
          presentacionId: presentationId,
          productName: 'Amox',
          presentationName: 'Caja x 14',
          lote: 'LOTE-A',
          fechaVencimiento: now.add(const Duration(days: 30)),
          fechaIngreso: now,
          stockActual: 10.0,
          precioCompraUnitario: 1.0,
        ),
      );

      // Lote B: 20 unidades, vence en 180 días
      await inventoryRepo.registerBatchEntry(
        BatchStock(
          presentacionId: presentationId,
          productName: 'Amox',
          presentationName: 'Caja x 14',
          lote: 'LOTE-B',
          fechaVencimiento: now.add(const Duration(days: 180)),
          fechaIngreso: now,
          stockActual: 20.0,
          precioCompraUnitario: 1.0,
        ),
      );

      // Solicitamos 15 unidades (debe agotar las 10 de Lote A y tomar 5 de Lote B)
      final allocations = await inventoryRepo.allocateFefoStock(
        presentationId,
        15.0,
        documentoReferencia: 'FAC-001-001-0001',
      );

      expect(allocations.length, equals(2));
      expect(allocations[0].lot.lotNumber, equals('LOTE-A'));
      expect(allocations[0].quantityDeducted, equals(10.0));
      expect(allocations[1].lot.lotNumber, equals('LOTE-B'));
      expect(allocations[1].quantityDeducted, equals(5.0));

      // Verificar persistencia de stock remanente
      final updatedBatches = await inventoryRepo.getBatchesForPresentation(presentationId);
      final batchA = updatedBatches.firstWhere((b) => b.lote == 'LOTE-A');
      final batchB = updatedBatches.firstWhere((b) => b.lote == 'LOTE-B');
      expect(batchA.stockActual, equals(0.0));
      expect(batchB.stockActual, equals(15.0));

      // Verificar movimientos de salida_venta en Kardex
      final kardexA = await inventoryRepo.getKardexMovements(batchId: batchA.id);
      expect(kardexA.any((m) => m.tipo == 'salida_venta' && m.cantidad == 10.0), isTrue);

      final kardexB = await inventoryRepo.getKardexMovements(batchId: batchB.id);
      expect(kardexB.any((m) => m.tipo == 'salida_venta' && m.cantidad == 5.0), isTrue);
    });

    test('adjustStock modifica stock y genera ajuste_positivo o ajuste_negativo según corresponda', () async {
      final now = DateTime.now();
      final batchId = await inventoryRepo.registerBatchEntry(
        BatchStock(
          presentacionId: presentationId,
          productName: 'Amox',
          presentationName: 'Caja x 14',
          lote: 'LOTE-ADJUST',
          fechaVencimiento: now.add(const Duration(days: 90)),
          fechaIngreso: now,
          stockActual: 20.0,
        ),
      );

      // Ajuste positivo: de 20 a 25
      await inventoryRepo.adjustStock(batchId, 25.0, 'Conteo físico: sobrante en percha');
      var batches = await inventoryRepo.getBatchesForPresentation(presentationId);
      expect(batches.first.stockActual, equals(25.0));

      var movements = await inventoryRepo.getKardexMovements(batchId: batchId);
      expect(movements.any((m) => m.tipo == 'ajuste_positivo' && m.cantidad == 5.0), isTrue);

      // Ajuste negativo: de 25 a 22
      await inventoryRepo.adjustStock(batchId, 22.0, 'Merma por ampolla rota');
      batches = await inventoryRepo.getBatchesForPresentation(presentationId);
      expect(batches.first.stockActual, equals(22.0));

      movements = await inventoryRepo.getKardexMovements(batchId: batchId);
      expect(movements.any((m) => m.tipo == 'ajuste_negativo' && m.cantidad == 3.0), isTrue);
    });

    test('Filtros de lotes vencidos, próximos a vencer y con stock', () async {
      final now = DateTime.now();

      // Lote Vencido (hace 10 días)
      await inventoryRepo.registerBatchEntry(
        BatchStock(
          presentacionId: presentationId,
          productName: 'Amox',
          presentationName: 'Caja',
          lote: 'LOTE-VENCIDO',
          fechaVencimiento: now.subtract(const Duration(days: 10)),
          fechaIngreso: now.subtract(const Duration(days: 400)),
          stockActual: 5.0,
        ),
      );

      // Lote Próximo a vencer (en 30 días)
      await inventoryRepo.registerBatchEntry(
        BatchStock(
          presentacionId: presentationId,
          productName: 'Amox',
          presentationName: 'Caja',
          lote: 'LOTE-POR-VENCER',
          fechaVencimiento: now.add(const Duration(days: 30)),
          fechaIngreso: now,
          stockActual: 8.0,
        ),
      );

      // Lote Lejano (en 300 días) con stock 0
      await inventoryRepo.registerBatchEntry(
        BatchStock(
          presentacionId: presentationId,
          productName: 'Amox',
          presentationName: 'Caja',
          lote: 'LOTE-AGOTADO',
          fechaVencimiento: now.add(const Duration(days: 300)),
          fechaIngreso: now,
          stockActual: 0.0,
        ),
      );

      // 1. Filtro vencidos
      final expired = await inventoryRepo.getAllBatches(onlyExpired: true);
      expect(expired.length, equals(1));
      expect(expired.first.lote, equals('LOTE-VENCIDO'));

      // 2. Filtro por vencer (próximos 90 días)
      final expiringSoon = await inventoryRepo.getAllBatches(onlyExpiringSoon: true);
      expect(expiringSoon.length, equals(1));
      expect(expiringSoon.first.lote, equals('LOTE-POR-VENCER'));

      // 3. Filtro solo con stock
      final withStock = await inventoryRepo.getAllBatches(onlyWithStock: true);
      expect(withStock.any((b) => b.lote == 'LOTE-AGOTADO'), isFalse);
      expect(withStock.length, equals(2));
    });
  });
}
