import 'package:drift/drift.dart';

enum UserRole {
  administrador,
  farmaceutico,
  cajero,
}

/// Tabla que almacena los usuarios del sistema para autenticación y autorización.
class UsuariosTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 3, max: 50).unique()();
  TextColumn get passwordHash => text()(); // SHA-256
  IntColumn get role => intEnum<UserRole>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get requiresPasswordChange => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Datos de Personal
  TextColumn get fullName => text().nullable()();
  TextColumn get documento => text().nullable()();
  TextColumn get telefonoFijo => text().nullable()();
  TextColumn get telefonoMovil => text().nullable()();
  TextColumn get correoPersonal => text().nullable()();
  DateTimeColumn get hireDate => dateTime().nullable()();
}
