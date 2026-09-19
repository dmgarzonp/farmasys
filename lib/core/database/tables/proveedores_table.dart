import 'package:drift/drift.dart';

/// Registro de distribuidores y proveedores farmacéuticos
class ProveedoresTable extends Table {
  @override
  String get tableName => 'proveedores';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get ruc => text().withLength(min: 13, max: 13)();
  TextColumn get nombreEmpresa => text().withLength(min: 2, max: 200)();
  TextColumn get direccion => text().nullable()();
  TextColumn get telefonoEmpresa => text().nullable()();
  TextColumn get emailEmpresa => text().nullable()();

  // Contacto directo
  TextColumn get nombreContacto => text().nullable()();
  TextColumn get telefonoContacto => text().nullable()();
  TextColumn get emailContacto => text().nullable()();

  TextColumn get estado => text().withDefault(const Constant('activo'))(); // activo / inactivo
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
