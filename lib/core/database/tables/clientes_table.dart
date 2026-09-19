import 'package:drift/drift.dart';

/// Directorio de clientes para emisión de facturas electrónicas SRI
class ClientesTable extends Table {
  @override
  String get tableName => 'clientes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get documento => text().withLength(min: 10, max: 13)(); // Cédula (10) o RUC (13)
  TextColumn get tipoDocumento => text().withDefault(const Constant('05'))(); // 04=RUC, 05=Cédula, 06=Pasaporte, 07=Consumidor Final
  TextColumn get nombreCompleto => text().withLength(min: 2, max: 200)();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get direccion => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
