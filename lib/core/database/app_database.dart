import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/productos_table.dart';
import 'tables/presentaciones_table.dart';
import 'tables/lotes_table.dart';
import 'tables/movimientos_stock_table.dart';
import 'tables/ventas_table.dart';
import 'tables/detalles_venta_table.dart';
import 'tables/clientes_table.dart';
import 'tables/proveedores_table.dart';
import 'tables/cajas_sesiones_table.dart';
import 'tables/compras_table.dart';
import 'tables/detalles_compra_table.dart';
import 'database_seeder.dart';

part 'app_database.g.dart';

/// Base de datos SQLite local central de FarmSys ejecutada con Drift.
/// Diseñada para aislamiento en background isolate (60 FPS garantizados).
@DriftDatabase(tables: [
  ProductosTable,
  PresentacionesTable,
  LotesTable,
  MovimientosStockTable,
  VentasTable,
  DetallesVentaTable,
  ClientesTable,
  ProveedoresTable,
  CajasSesionesTable,
  ComprasTable,
  DetallesCompraTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Seed inicial: Consumidor Final obligatorio para facturación
          await into(clientesTable).insert(
            ClientesTableCompanion.insert(
              documento: '9999999999999',
              tipoDocumento: const Value('07'),
              nombreCompleto: 'CONSUMIDOR FINAL',
              direccion: const Value('S/D'),
            ),
          );

          // Ejecutar semilla de datos de prueba
          await DatabaseSeeder.run(this);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(comprasTable);
            await m.createTable(detallesCompraTable);
          }
        },
        beforeOpen: (details) async {
          // Habilitar Foreign Keys y modo WAL para alta concurrencia
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = NORMAL');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'farmsys_demo_db',
    );
  }
}

/// Proveedor Riverpod para inyección de dependencias de la base de datos (SOLID: DIP)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
