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
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'tables/usuarios_table.dart';
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
  UsuariosTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 9;

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
          if (from < 3) {
            await m.addColumn(proveedoresTable, proveedoresTable.saldoAFavor);
          }
          if (from < 4) {
            await m.createTable(usuariosTable);
            
            // Insertar admin por defecto al migrar
            final adminPasswordHash = sha256.convert(utf8.encode('admin123')).toString();
            await into(usuariosTable).insert(
              UsuariosTableCompanion.insert(
                id: const Value(1),
                username: 'admin',
                passwordHash: adminPasswordHash,
                role: UserRole.administrador,
              ),
            );
          }
          if (from < 5) {
            // Asegurar que el admin exista si la migración 4 no lo creó
            final adminPasswordHash = sha256.convert(utf8.encode('admin123')).toString();
            final existingAdmin = await customSelect('SELECT id FROM usuarios_table WHERE username = \'admin\'').get();
            if (existingAdmin.isEmpty) {
              await into(usuariosTable).insert(
                UsuariosTableCompanion.insert(
                  id: const Value(1),
                  username: 'admin',
                  passwordHash: adminPasswordHash,
                  role: UserRole.administrador,
                ),
              );
            }
          }
          if (from < 6) {
            await m.addColumn(usuariosTable, usuariosTable.fullName);
            await m.addColumn(usuariosTable, usuariosTable.documento);
            await m.addColumn(usuariosTable, usuariosTable.telefonoFijo); // Reused the space of old 'telefono'
            await m.addColumn(usuariosTable, usuariosTable.hireDate);
          }
          if (from < 7) {
            await m.addColumn(usuariosTable, usuariosTable.telefonoMovil);
            await m.addColumn(usuariosTable, usuariosTable.correoPersonal);
          }
          if (from < 8) {
            // Hotfix: telefonoFijo se añadió a la clase pero no a la migración para bases de datos que ya estaban en v6.
            try {
              await m.addColumn(usuariosTable, usuariosTable.telefonoFijo);
            } catch (e) {
              // Ignore if already exists (for databases that updated straight from v5 to v7)
            }
          }
          if (from < 9) {
            await m.addColumn(usuariosTable, usuariosTable.requiresPasswordChange);
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
