import 'package:drift/drift.dart';
import 'app_database.dart';

class DatabaseSeeder {
  static Future<void> run(AppDatabase db) async {
    await db.batch((batch) {
      // 1. Productos
      batch.insertAll(db.productosTable, [
        ProductosTableCompanion.insert(
          id: const Value(1),
          nombreComercial: 'Paracetamol',
          principioActivo: const Value('Paracetamol'),
          concentracion: const Value('500mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(2),
          nombreComercial: 'Amoxicilina',
          principioActivo: const Value('Amoxicilina'),
          concentracion: const Value('500mg'),
          esAntibiotico: const Value(true),
          requiereReceta: const Value(true),
        ),
        ProductosTableCompanion.insert(
          id: const Value(3),
          nombreComercial: 'Ibuprofeno',
          principioActivo: const Value('Ibuprofeno'),
          concentracion: const Value('400mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(4),
          nombreComercial: 'Losartán',
          principioActivo: const Value('Losartán Potásico'),
          concentracion: const Value('50mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(true),
        ),
        ProductosTableCompanion.insert(
          id: const Value(5),
          nombreComercial: 'Vitamina C',
          principioActivo: const Value('Ácido Ascórbico'),
          concentracion: const Value('1g'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
      ]);

      // 2. Presentaciones
      batch.insertAll(db.presentacionesTable, [
        // Presentaciones de Paracetamol (id 1)
        PresentacionesTableCompanion.insert(
          id: const Value(1),
          productoId: 1,
          nombreDescriptivo: 'Caja x 100 tabletas',
          unidadesPorCaja: const Value(100),
          precioCompraCaja: const Value(2.50),
          precioVentaCaja: const Value(4.00),
          precioVentaFraccion: const Value(0.05),
          stockMinimo: const Value(10),
          codigoBarras: const Value('7861000000011'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Amoxicilina (id 2)
        PresentacionesTableCompanion.insert(
          id: const Value(2),
          productoId: 2,
          nombreDescriptivo: 'Frasco x 60ml Suspensión',
          unidadesPorCaja: const Value(1),
          precioCompraCaja: const Value(3.00),
          precioVentaCaja: const Value(4.50),
          precioVentaFraccion: const Value(4.50),
          stockMinimo: const Value(5),
          codigoBarras: const Value('7861000000022'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Ibuprofeno (id 3)
        PresentacionesTableCompanion.insert(
          id: const Value(3),
          productoId: 3,
          nombreDescriptivo: 'Caja x 50 cápsulas líquidas',
          unidadesPorCaja: const Value(50),
          precioCompraCaja: const Value(5.00),
          precioVentaCaja: const Value(8.00),
          precioVentaFraccion: const Value(0.20),
          stockMinimo: const Value(15), // Alerta Reposición
          codigoBarras: const Value('7861000000033'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Losartán (id 4)
        PresentacionesTableCompanion.insert(
          id: const Value(4),
          productoId: 4,
          nombreDescriptivo: 'Caja x 30 tabletas recubiertas',
          unidadesPorCaja: const Value(30),
          precioCompraCaja: const Value(3.50),
          precioVentaCaja: const Value(5.50),
          precioVentaFraccion: const Value(0.25),
          stockMinimo: const Value(8),
          codigoBarras: const Value('7861000000044'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Vitamina C (id 5)
        PresentacionesTableCompanion.insert(
          id: const Value(5),
          productoId: 5,
          nombreDescriptivo: 'Caja x 10 tabletas efervescentes',
          unidadesPorCaja: const Value(10),
          precioCompraCaja: const Value(4.00),
          precioVentaCaja: const Value(6.00),
          precioVentaFraccion: const Value(0.70),
          stockMinimo: const Value(5),
          codigoBarras: const Value('7861000000055'),
          tieneIva: const Value(true), // Paga IVA
        ),
      ]);

      // 3. Lotes (Stock físico e historial de vencimiento)
      final now = DateTime.now();
      
      batch.insertAll(db.lotesTable, [
        // Lote 1: Paracetamol (Stock normal, vence en 1 año) -> Sin alerta
        LotesTableCompanion.insert(
          presentacionId: 1,
          lote: 'L-GEN-001',
          fechaVencimiento: now.add(const Duration(days: 365)),
          stockActual: const Value(50.0),
          precioCompraCaja: const Value(2.50),
          precioCompraUnitario: const Value(0.025),
          ubicacion: const Value('Estante A'),
        ),
        // Lote 2: Amoxicilina (Vence en 20 días) -> Alerta Roja (Crítica)
        LotesTableCompanion.insert(
          presentacionId: 2,
          lote: 'L-MK-002',
          fechaVencimiento: now.add(const Duration(days: 20)),
          stockActual: const Value(15.0),
          precioCompraCaja: const Value(3.00),
          precioCompraUnitario: const Value(3.00),
          ubicacion: const Value('Estante B'),
        ),
        // Lote 3: Losartán (Vence en 60 días) -> Alerta Naranja (Advertencia)
        LotesTableCompanion.insert(
          presentacionId: 4,
          lote: 'L-NIF-003',
          fechaVencimiento: now.add(const Duration(days: 60)),
          stockActual: const Value(25.0),
          precioCompraCaja: const Value(3.50),
          precioCompraUnitario: const Value(0.116),
          ubicacion: const Value('Estante A'),
        ),
        // Lote 4: Ibuprofeno (Bajo stock total: min 15, stock actual 5) -> Alerta de Reposición
        LotesTableCompanion.insert(
          presentacionId: 3,
          lote: 'L-BAY-004',
          fechaVencimiento: now.add(const Duration(days: 730)), // Vence en 2 años
          stockActual: const Value(5.0), // Quedan muy pocos
          precioCompraCaja: const Value(5.00),
          precioCompraUnitario: const Value(0.10),
          ubicacion: const Value('Gaveta 1'),
        ),
        // Lote 5: Vitamina C
        LotesTableCompanion.insert(
          presentacionId: 5,
          lote: 'L-CEB-005',
          fechaVencimiento: now.add(const Duration(days: 120)),
          stockActual: const Value(40.0),
          precioCompraCaja: const Value(4.00),
          precioCompraUnitario: const Value(0.40),
          ubicacion: const Value('Exhibidor'),
        ),
      ]);
    });
  }
}
