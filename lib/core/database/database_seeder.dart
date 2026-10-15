import 'package:drift/drift.dart';
import 'app_database.dart';
import 'tables/usuarios_table.dart';

class DatabaseSeeder {
  /// Hash precalculado con sal criptográfica de la contraseña inicial por defecto.
  /// Evita que cadenas en texto plano ('admin123') o hashes planos vulnerables
  /// a tablas arcoíris queden expuestos en el binario o en la base de datos SQLite.
  static const String defaultAdminPasswordHash =
      'v1\$d4e5f6a1b2c37890\$5cbea506320748620e4993a9ea6234fd6f25d06de7545b3275f63beaa88a2289';

  static Future<void> run(AppDatabase db) async {
    await db.batch((batch) {
      // 0. Usuarios (Admin por defecto)
      batch.insertAll(db.usuariosTable, [
        UsuariosTableCompanion.insert(
          id: const Value(1),
          username: 'admin',
          passwordHash: defaultAdminPasswordHash,
          role: UserRole.administrador,
        ),
      ]);

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
        ProductosTableCompanion.insert(
          id: const Value(6),
          nombreComercial: 'Omeprazol',
          principioActivo: const Value('Omeprazol'),
          concentracion: const Value('20mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(7),
          nombreComercial: 'Azitromicina',
          principioActivo: const Value('Azitromicina Dihidrato'),
          concentracion: const Value('500mg'),
          esAntibiotico: const Value(true),
          requiereReceta: const Value(true),
        ),
        ProductosTableCompanion.insert(
          id: const Value(8),
          nombreComercial: 'Loratadina',
          principioActivo: const Value('Loratadina'),
          concentracion: const Value('10mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(9),
          nombreComercial: 'Metformina',
          principioActivo: const Value('Metformina Clorhidrato'),
          concentracion: const Value('850mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(true),
        ),
        ProductosTableCompanion.insert(
          id: const Value(10),
          nombreComercial: 'Cetirizina',
          principioActivo: const Value('Cetirizina Diclorhidrato'),
          concentracion: const Value('10mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(11),
          nombreComercial: 'Diclofenaco Sódico',
          principioActivo: const Value('Diclofenaco Sódico'),
          concentracion: const Value('50mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(12),
          nombreComercial: 'Complejo B Forte',
          principioActivo: const Value('Tiamina + Piridoxina + Cianocobalamina'),
          concentracion: const Value('Inyectable 2ml'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(13),
          nombreComercial: 'Simvastatina',
          principioActivo: const Value('Simvastatina'),
          concentracion: const Value('20mg'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(true),
        ),
        ProductosTableCompanion.insert(
          id: const Value(14),
          nombreComercial: 'Suero Oral Electrolitos',
          principioActivo: const Value('Sales de Rehidratación Oral'),
          concentracion: const Value('500ml Manzana'),
          esAntibiotico: const Value(false),
          requiereReceta: const Value(false),
        ),
        ProductosTableCompanion.insert(
          id: const Value(15),
          nombreComercial: 'Alcohol Antiséptico 70%',
          principioActivo: const Value('Alcohol Etílico Desnaturalizado'),
          concentracion: const Value('1000ml'),
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
          stockMinimo: const Value(15),
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
        // Presentaciones de Omeprazol (id 6)
        PresentacionesTableCompanion.insert(
          id: const Value(6),
          productoId: 6,
          nombreDescriptivo: 'Caja x 30 cápsulas con microgránulos',
          unidadesPorCaja: const Value(30),
          precioCompraCaja: const Value(3.20),
          precioVentaCaja: const Value(5.00),
          precioVentaFraccion: const Value(0.20),
          stockMinimo: const Value(10),
          codigoBarras: const Value('7861000000066'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Azitromicina (id 7)
        PresentacionesTableCompanion.insert(
          id: const Value(7),
          productoId: 7,
          nombreDescriptivo: 'Caja x 3 tabletas 500mg',
          unidadesPorCaja: const Value(3),
          precioCompraCaja: const Value(2.80),
          precioVentaCaja: const Value(4.80),
          precioVentaFraccion: const Value(1.70),
          stockMinimo: const Value(5),
          codigoBarras: const Value('7861000000077'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Loratadina (id 8)
        PresentacionesTableCompanion.insert(
          id: const Value(8),
          productoId: 8,
          nombreDescriptivo: 'Caja x 20 tabletas 10mg',
          unidadesPorCaja: const Value(20),
          precioCompraCaja: const Value(1.50),
          precioVentaCaja: const Value(3.00),
          precioVentaFraccion: const Value(0.20),
          stockMinimo: const Value(10),
          codigoBarras: const Value('7861000000088'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Metformina (id 9)
        PresentacionesTableCompanion.insert(
          id: const Value(9),
          productoId: 9,
          nombreDescriptivo: 'Caja x 30 tabletas 850mg',
          unidadesPorCaja: const Value(30),
          precioCompraCaja: const Value(2.20),
          precioVentaCaja: const Value(4.20),
          precioVentaFraccion: const Value(0.18),
          stockMinimo: const Value(8),
          codigoBarras: const Value('7861000000099'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Cetirizina (id 10)
        PresentacionesTableCompanion.insert(
          id: const Value(10),
          productoId: 10,
          nombreDescriptivo: 'Caja x 20 tabletas 10mg',
          unidadesPorCaja: const Value(20),
          precioCompraCaja: const Value(1.80),
          precioVentaCaja: const Value(3.50),
          precioVentaFraccion: const Value(0.22),
          stockMinimo: const Value(8),
          codigoBarras: const Value('7861000000105'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Diclofenaco (id 11)
        PresentacionesTableCompanion.insert(
          id: const Value(11),
          productoId: 11,
          nombreDescriptivo: 'Caja x 30 tabletas 50mg',
          unidadesPorCaja: const Value(30),
          precioCompraCaja: const Value(1.60),
          precioVentaCaja: const Value(3.20),
          precioVentaFraccion: const Value(0.15),
          stockMinimo: const Value(10),
          codigoBarras: const Value('7861000000112'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Complejo B (id 12)
        PresentacionesTableCompanion.insert(
          id: const Value(12),
          productoId: 12,
          nombreDescriptivo: 'Caja x 3 ampollas inyectables',
          unidadesPorCaja: const Value(3),
          precioCompraCaja: const Value(3.50),
          precioVentaCaja: const Value(5.80),
          precioVentaFraccion: const Value(2.10),
          stockMinimo: const Value(6),
          codigoBarras: const Value('7861000000129'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Simvastatina (id 13)
        PresentacionesTableCompanion.insert(
          id: const Value(13),
          productoId: 13,
          nombreDescriptivo: 'Caja x 30 tabletas 20mg',
          unidadesPorCaja: const Value(30),
          precioCompraCaja: const Value(4.00),
          precioVentaCaja: const Value(6.50),
          precioVentaFraccion: const Value(0.30),
          stockMinimo: const Value(5),
          codigoBarras: const Value('7861000000136'),
          tieneIva: const Value(false),
        ),
        // Presentaciones de Suero Oral (id 14)
        PresentacionesTableCompanion.insert(
          id: const Value(14),
          productoId: 14,
          nombreDescriptivo: 'Frasco x 500ml Bebible',
          unidadesPorCaja: const Value(1),
          precioCompraCaja: const Value(1.20),
          precioVentaCaja: const Value(2.25),
          precioVentaFraccion: const Value(2.25),
          stockMinimo: const Value(12),
          codigoBarras: const Value('7861000000143'),
          tieneIva: const Value(true), // Paga IVA
        ),
        // Presentaciones de Alcohol Antiséptico (id 15)
        PresentacionesTableCompanion.insert(
          id: const Value(15),
          productoId: 15,
          nombreDescriptivo: 'Botella x 1000ml con dispensador',
          unidadesPorCaja: const Value(1),
          precioCompraCaja: const Value(2.10),
          precioVentaCaja: const Value(3.75),
          precioVentaFraccion: const Value(3.75),
          stockMinimo: const Value(10),
          codigoBarras: const Value('7861000000150'),
          tieneIva: const Value(true), // Paga IVA
        ),
      ]);

      // 3. Lotes (Stock físico e historial de vencimiento FEFO)
      final now = DateTime.now();
      
      batch.insertAll(db.lotesTable, [
        // Lote 1: Paracetamol (Stock normal, vence en 1 año)
        LotesTableCompanion.insert(
          presentacionId: 1,
          lote: 'L-GEN-001',
          fechaVencimiento: now.add(const Duration(days: 365)),
          stockActual: const Value(50.0),
          precioCompraCaja: const Value(2.50),
          precioCompraUnitario: const Value(0.025),
          ubicacion: const Value('Estante A'),
        ),
        // Lote 2: Amoxicilina (Vence en 20 días) -> Alerta Roja
        LotesTableCompanion.insert(
          presentacionId: 2,
          lote: 'L-MK-002',
          fechaVencimiento: now.add(const Duration(days: 20)),
          stockActual: const Value(15.0),
          precioCompraCaja: const Value(3.00),
          precioCompraUnitario: const Value(3.00),
          ubicacion: const Value('Estante B'),
        ),
        // Lote 3: Losartán (Vence en 60 días) -> Alerta Naranja
        LotesTableCompanion.insert(
          presentacionId: 4,
          lote: 'L-NIF-003',
          fechaVencimiento: now.add(const Duration(days: 60)),
          stockActual: const Value(25.0),
          precioCompraCaja: const Value(3.50),
          precioCompraUnitario: const Value(0.116),
          ubicacion: const Value('Estante A'),
        ),
        // Lote 4: Ibuprofeno (Bajo stock total: min 15, stock 5) -> Alerta Reposición
        LotesTableCompanion.insert(
          presentacionId: 3,
          lote: 'L-BAY-004',
          fechaVencimiento: now.add(const Duration(days: 730)),
          stockActual: const Value(5.0),
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
        // Lote 6: Omeprazol
        LotesTableCompanion.insert(
          presentacionId: 6,
          lote: 'L-OMP-006',
          fechaVencimiento: now.add(const Duration(days: 450)),
          stockActual: const Value(30.0),
          precioCompraCaja: const Value(3.20),
          precioCompraUnitario: const Value(0.106),
          ubicacion: const Value('Estante B'),
        ),
        // Lote 7: Azitromicina
        LotesTableCompanion.insert(
          presentacionId: 7,
          lote: 'L-AZT-007',
          fechaVencimiento: now.add(const Duration(days: 500)),
          stockActual: const Value(20.0),
          precioCompraCaja: const Value(2.80),
          precioCompraUnitario: const Value(0.933),
          ubicacion: const Value('Estante C'),
        ),
        // Lote 8: Loratadina
        LotesTableCompanion.insert(
          presentacionId: 8,
          lote: 'L-LOR-008',
          fechaVencimiento: now.add(const Duration(days: 300)),
          stockActual: const Value(35.0),
          precioCompraCaja: const Value(1.50),
          precioCompraUnitario: const Value(0.075),
          ubicacion: const Value('Estante A'),
        ),
        // Lote 9: Metformina
        LotesTableCompanion.insert(
          presentacionId: 9,
          lote: 'L-MET-009',
          fechaVencimiento: now.add(const Duration(days: 400)),
          stockActual: const Value(25.0),
          precioCompraCaja: const Value(2.20),
          precioCompraUnitario: const Value(0.073),
          ubicacion: const Value('Estante D'),
        ),
        // Lote 10: Cetirizina
        LotesTableCompanion.insert(
          presentacionId: 10,
          lote: 'L-CET-010',
          fechaVencimiento: now.add(const Duration(days: 320)),
          stockActual: const Value(28.0),
          precioCompraCaja: const Value(1.80),
          precioCompraUnitario: const Value(0.09),
          ubicacion: const Value('Estante A'),
        ),
        // Lote 11: Diclofenaco
        LotesTableCompanion.insert(
          presentacionId: 11,
          lote: 'L-DIC-011',
          fechaVencimiento: now.add(const Duration(days: 280)),
          stockActual: const Value(45.0),
          precioCompraCaja: const Value(1.60),
          precioCompraUnitario: const Value(0.053),
          ubicacion: const Value('Estante B'),
        ),
        // Lote 12: Complejo B
        LotesTableCompanion.insert(
          presentacionId: 12,
          lote: 'L-CPB-012',
          fechaVencimiento: now.add(const Duration(days: 210)),
          stockActual: const Value(18.0),
          precioCompraCaja: const Value(3.50),
          precioCompraUnitario: const Value(1.166),
          ubicacion: const Value('Refrigerador 2'),
        ),
        // Lote 13: Simvastatina
        LotesTableCompanion.insert(
          presentacionId: 13,
          lote: 'L-SIM-013',
          fechaVencimiento: now.add(const Duration(days: 600)),
          stockActual: const Value(22.0),
          precioCompraCaja: const Value(4.00),
          precioCompraUnitario: const Value(0.133),
          ubicacion: const Value('Estante D'),
        ),
        // Lote 14: Suero Oral
        LotesTableCompanion.insert(
          presentacionId: 14,
          lote: 'L-SRO-014',
          fechaVencimiento: now.add(const Duration(days: 360)),
          stockActual: const Value(50.0),
          precioCompraCaja: const Value(1.20),
          precioCompraUnitario: const Value(1.20),
          ubicacion: const Value('Góndola 1'),
        ),
        // Lote 15: Alcohol Antiséptico
        LotesTableCompanion.insert(
          presentacionId: 15,
          lote: 'L-ALC-015',
          fechaVencimiento: now.add(const Duration(days: 720)),
          stockActual: const Value(60.0),
          precioCompraCaja: const Value(2.10),
          precioCompraUnitario: const Value(2.10),
          ubicacion: const Value('Bodega Principal'),
        ),
      ]);
    });
  }
}
