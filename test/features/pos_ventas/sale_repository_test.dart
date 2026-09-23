import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/caja/data/repositories/drift_cash_session_repository.dart';
import 'package:farmsys/features/caja/domain/repositories/i_cash_session_repository.dart';
import 'package:farmsys/features/catalogo_productos/data/repositories/drift_product_repository.dart';
import 'package:farmsys/features/catalogo_productos/domain/entities/product.dart';
import 'package:farmsys/features/inventario/data/repositories/drift_inventory_repository.dart';
import 'package:farmsys/features/inventario/domain/entities/batch_stock.dart';
import 'package:farmsys/features/inventario/domain/repositories/i_inventory_repository.dart';
import 'package:farmsys/features/pos_ventas/data/repositories/drift_sale_repository.dart';
import 'package:farmsys/features/pos_ventas/domain/entities/cart_item.dart';
import 'package:farmsys/features/pos_ventas/domain/entities/sale.dart';
import 'package:farmsys/features/pos_ventas/domain/repositories/i_sale_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  late AppDatabase database;
  late IInventoryRepository inventoryRepo;
  late ICashSessionRepository cashRepo;
  late ISaleRepository saleRepo;
  late int presentationId;
  late int sessionId;

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
    cashRepo = DriftCashSessionRepository(database);
    saleRepo = DriftSaleRepository(database, inventoryRepo, cashRepo, 0.15);

    // 1. Crear producto con presentación
    final productRepo = DriftProductRepository(database);
    final prodId = await productRepo.saveProduct(
      const Product(
        nombreComercial: 'Ibuprofeno 400mg Forte',
        principioActivo: 'Ibuprofeno',
        presentaciones: [
          ProductPresentation(
            nombreDescriptivo: 'Caja x 30 tabletas',
            unidadesPorCaja: 30,
            precioCompraCaja: 3.00,
            precioVentaCaja: 6.00,
            tieneIva: false, // Medicamento 0%
          ),
        ],
      ),
    );

    final product = await productRepo.getProductById(prodId);
    presentationId = product!.presentaciones.first.id!;

    // 2. Ingresar 2 lotes con diferentes vencimientos
    final now = DateTime.now();
    await inventoryRepo.registerBatchEntry(
      BatchStock(
        presentacionId: presentationId,
        productName: 'Ibuprofeno',
        presentationName: 'Caja x 30',
        lote: 'LOTE-FEFO-1',
        fechaVencimiento: now.add(const Duration(days: 30)), // Vence en 30 días
        fechaIngreso: now,
        stockActual: 10.0,
      ),
    );

    await inventoryRepo.registerBatchEntry(
      BatchStock(
        presentacionId: presentationId,
        productName: 'Ibuprofeno',
        presentationName: 'Caja x 30',
        lote: 'LOTE-FEFO-2',
        fechaVencimiento: now.add(const Duration(days: 180)), // Vence en 180 días
        fechaIngreso: now,
        stockActual: 20.0,
      ),
    );

    // 3. Abrir turno de caja
    final session = await cashRepo.openSession(usuarioId: 1, montoInicial: 50.0);
    sessionId = session.id!;
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftSaleRepository - Procesamiento de Venta y FEFO Atómico (SOLID: DIP)', () {
    test('Procesa venta deduciendo lotes secuencialmente y actualiza caja y Kardex', () async {
      // Solicitamos 15 unidades de Ibuprofeno a $6.00 = $90.00 total
      // Debe agotar las 10 unidades de LOTE-FEFO-1 y tomar 5 de LOTE-FEFO-2
      final cartItem = CartItem(
        presentacionId: presentationId,
        productoNombre: 'Ibuprofeno 400mg Forte',
        presentacionNombre: 'Caja x 30 tabletas',
        unitPrice: 6.00,
        quantity: 15.0,
        hasIva: false,
      );

      final saleHeader = Sale(
        usuarioId: 1,
        sesionCajaId: sessionId,
        fechaVenta: DateTime.now(),
        subtotal0: 90.00,
        subtotal12: 0.00,
        impuestoTotal: 0.00,
        total: 90.00,
        metodoPago: 'efectivo',
      );

      final completedSale = await saleRepo.processSale(
        saleHeader: saleHeader,
        cartItems: [cartItem],
      );

      expect(completedSale.id, greaterThan(0));
      expect(completedSale.detalles.length, equals(2));

      // Verificamos los renglones despachados por lote
      final detailLot1 = completedSale.detalles.firstWhere((d) => d.loteCodigo == 'LOTE-FEFO-1');
      final detailLot2 = completedSale.detalles.firstWhere((d) => d.loteCodigo == 'LOTE-FEFO-2');
      expect(detailLot1.cantidad, equals(10.0));
      expect(detailLot2.cantidad, equals(5.0));

      // Verificamos persistencia de stock remanente
      final batches = await inventoryRepo.getBatchesForPresentation(presentationId);
      final batch1 = batches.firstWhere((b) => b.lote == 'LOTE-FEFO-1');
      final batch2 = batches.firstWhere((b) => b.lote == 'LOTE-FEFO-2');
      expect(batch1.stockActual, equals(0.0));
      expect(batch2.stockActual, equals(15.0));

      // Verificamos actualización de dinero en caja
      final activeSession = await cashRepo.getActiveSession();
      expect(activeSession!.montoEsperadoEfectivo, equals(90.00));

      // Verificamos consulta por ID
      final retrieved = await saleRepo.getSaleById(completedSale.id!);
      expect(retrieved, isNotNull);
      expect(retrieved!.total, equals(90.00));
      expect(retrieved.detalles.length, equals(2));
    });
  });
}
