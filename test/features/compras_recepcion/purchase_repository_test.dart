import 'dart:ffi';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:farmsys/core/constants/app_constants.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/compras_recepcion/data/repositories/drift_purchase_repository.dart';
import 'package:farmsys/features/compras_recepcion/domain/entities/purchase_invoice.dart';
import 'package:farmsys/features/compras_recepcion/domain/entities/purchase_item.dart';
import 'package:farmsys/features/compras_recepcion/domain/repositories/i_purchase_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  late AppDatabase database;
  late IPurchaseRepository purchaseRepo;
  late int proveedorId;
  late int presentacionIvaCeroId;
  late int presentacionIvaDoceId;

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
    purchaseRepo = DriftPurchaseRepository(database);

    // Seed Proveedor
    proveedorId = await database.into(database.proveedoresTable).insert(
          ProveedoresTableCompanion.insert(
            ruc: '1790016919001',
            nombreEmpresa: 'DIFARUM CÍA. LTDA.',
          ),
        );

    // Seed Producto 1: Medicamento Humano (IVA 0%)
    final prod1Id = await database.into(database.productosTable).insert(
          ProductosTableCompanion.insert(
            nombreComercial: 'PARACETAMOL GENFAR 500 MG',
            principioActivo: const drift.Value('PARACETAMOL'),
            concentracion: const drift.Value('500 mg'),
          ),
        );
    presentacionIvaCeroId = await database.into(database.presentacionesTable).insert(
          PresentacionesTableCompanion.insert(
            productoId: prod1Id,
            nombreDescriptivo: 'Caja x 20 tabletas',
            unidadesPorCaja: const drift.Value(20),
            precioCompraCaja: const drift.Value(0.0),
            precioVentaCaja: const drift.Value(4.0),
            tieneIva: const drift.Value(false),
          ),
        );

    // Seed Producto 2: Cosmético / Protector Solar (IVA 12%)
    final prod2Id = await database.into(database.productosTable).insert(
          ProductosTableCompanion.insert(
            nombreComercial: 'BLOQUEADOR SOLAR FPS 50+',
          ),
        );
    presentacionIvaDoceId = await database.into(database.presentacionesTable).insert(
          PresentacionesTableCompanion.insert(
            productoId: prod2Id,
            nombreDescriptivo: 'Frasco 100ml',
            unidadesPorCaja: const drift.Value(1),
            precioCompraCaja: const drift.Value(0.0),
            precioVentaCaja: const drift.Value(15.0),
            tieneIva: const drift.Value(true),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftPurchaseRepository - Recepción de Facturas y Abastecimiento ARCSA (SOLID: DIP)', () {
    test('Registra factura multi-ítem, genera lotes, Kardex y actualiza costos atómicamente', () async {
      final expiryMed = DateTime(2027, 6, 30);
      final expiryCos = DateTime(2028, 12, 31);

      final invoice = PurchaseInvoice(
        proveedorId: proveedorId,
        proveedorNombre: 'DIFARUM CÍA. LTDA.',
        proveedorRuc: '1790016919001',
        numeroFactura: '001-001-000045678',
        numeroAutorizacionSri: '1709202601179001691900120010010000456781234567819',
        fechaEmision: DateTime(2026, 9, 15),
        fechaRecepcion: DateTime(2026, 9, 17),
        subtotalCero: 20.00, // 10 cajas x $2.00
        subtotalDoce: 50.00, // 5 unidades x $10.00
        iva: 6.00, // $50 * 12% = $6.00
        total: 76.00,
        items: [
          PurchaseItem(
            presentacionId: presentacionIvaCeroId,
            productoNombre: 'PARACETAMOL GENFAR 500 MG',
            presentacionNombre: 'Caja x 20 tabletas',
            lote: 'LOTE-MED-99',
            fechaVencimiento: expiryMed,
            cantidadCajas: 10,
            cantidadUnidades: 200, // 10 cajas * 20 tabletas
            unidadesPorCaja: 20,
            costoCaja: 2.00,
            costoUnitario: 0.10,
            tieneIva: false,
            subtotal: 20.00,
            cumpleRegistroSanitario: true,
            cumpleEmpaque: true,
          ),
          PurchaseItem(
            presentacionId: presentacionIvaDoceId,
            productoNombre: 'BLOQUEADOR SOLAR FPS 50+',
            presentacionNombre: 'Frasco 100ml',
            lote: 'LOTE-COS-12',
            fechaVencimiento: expiryCos,
            cantidadCajas: 5,
            cantidadUnidades: 5,
            unidadesPorCaja: 1,
            costoCaja: 10.00,
            costoUnitario: 10.00,
            tieneIva: true,
            subtotal: 50.00,
            cumpleRegistroSanitario: true,
            cumpleEmpaque: true,
          ),
        ],
      );

      // 1. Ejecutar recepción atómica
      final registered = await purchaseRepo.registerPurchase(invoice);
      expect(registered.id, isNotNull);
      expect(registered.items.length, equals(2));

      // 2. Verificar que los lotes físicos se hayan creado correctamente
      final lotes = await database.select(database.lotesTable).get();
      expect(lotes.length, equals(2));

      final loteMed = lotes.firstWhere((l) => l.presentacionId == presentacionIvaCeroId);
      expect(loteMed.lote, equals('LOTE-MED-99'));
      expect(loteMed.stockActual, equals(200.0));
      expect(loteMed.precioCompraCaja, equals(2.00));
      expect(loteMed.precioCompraUnitario, equals(0.10));

      final loteCos = lotes.firstWhere((l) => l.presentacionId == presentacionIvaDoceId);
      expect(loteCos.lote, equals('LOTE-COS-12'));
      expect(loteCos.stockActual, equals(5.0));

      // 3. Verificar asientos de Kardex inmutable
      final movimientos = await database.select(database.movimientosStockTable).get();
      expect(movimientos.length, equals(2));
      expect(movimientos.every((m) => m.tipo == StockMovementType.entradaCompra.code), isTrue);
      expect(movimientos.first.documentoReferencia, contains('001-001-000045678'));

      // 4. Verificar actualización de costo de compra en catálogo
      final presMed = await (database.select(database.presentacionesTable)
            ..where((t) => t.id.equals(presentacionIvaCeroId)))
          .getSingle();
      expect(presMed.precioCompraCaja, equals(2.00));

      // 5. Verificar consulta de historial y detalle
      final history = await purchaseRepo.getPurchases();
      expect(history.length, equals(1));
      expect(history.first.numeroFactura, equals('001-001-000045678'));
      expect(history.first.proveedorNombre, equals('DIFARUM CÍA. LTDA.'));

      final detail = await purchaseRepo.getPurchaseById(registered.id!);
      expect(detail, isNotNull);
      expect(detail!.items.length, equals(2));
      expect(detail.items.first.productoNombre, equals('PARACETAMOL GENFAR 500 MG'));
      expect(detail.todosConformesArcsa, isTrue);
    });

    test('Acumula stock físico si se recibe un lote existente previamente', () async {
      final itemLote = PurchaseItem(
        presentacionId: presentacionIvaCeroId,
        productoNombre: 'PARACETAMOL GENFAR 500 MG',
        presentacionNombre: 'Caja x 20 tabletas',
        lote: 'LOTE-REPETIDO',
        fechaVencimiento: DateTime(2027, 1, 1),
        cantidadCajas: 5,
        cantidadUnidades: 100,
        unidadesPorCaja: 20,
        costoCaja: 2.00,
        costoUnitario: 0.10,
        tieneIva: false,
        subtotal: 10.00,
      );

      final inv1 = PurchaseInvoice(
        proveedorId: proveedorId,
        proveedorNombre: 'DIFARUM',
        proveedorRuc: '1790016919001',
        numeroFactura: 'FAC-001',
        fechaEmision: DateTime.now(),
        fechaRecepcion: DateTime.now(),
        subtotalDoce: 0,
        subtotalCero: 10,
        iva: 0,
        total: 10,
        items: [itemLote],
      );

      await purchaseRepo.registerPurchase(inv1);

      // Segunda entrega con el mismo lote
      final inv2 = PurchaseInvoice(
        proveedorId: proveedorId,
        proveedorNombre: 'DIFARUM',
        proveedorRuc: '1790016919001',
        numeroFactura: 'FAC-002',
        fechaEmision: DateTime.now(),
        fechaRecepcion: DateTime.now(),
        subtotalDoce: 0,
        subtotalCero: 10,
        iva: 0,
        total: 10,
        items: [itemLote.copyWith(cantidadCajas: 3, cantidadUnidades: 60)],
      );

      await purchaseRepo.registerPurchase(inv2);

      // Solo debe existir 1 lote en base de datos, con stock acumulado = 160
      final lotes = await database.select(database.lotesTable).get();
      expect(lotes.length, equals(1));
      expect(lotes.first.stockActual, equals(160.0));
    });
  });
}
