import 'package:drift/drift.dart';

/// Tabla de catálogo de medicamentos y productos farmacéuticos
class ProductosTable extends Table {
  @override
  String get tableName => 'productos';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigoBarras => text().nullable()();
  TextColumn get nombreComercial => text().withLength(min: 1, max: 200)();
  TextColumn get principioActivo => text().nullable()();
  TextColumn get concentracion => text().nullable()();
  IntColumn get laboratorioId => integer().nullable()();
  IntColumn get categoriaId => integer().nullable()();

  // Banderas regulatorias para reporte ARCSA
  BoolColumn get requiereReceta => boolean().withDefault(const Constant(false))();
  BoolColumn get esPsicotropico => boolean().withDefault(const Constant(false))();
  BoolColumn get esAntibiotico => boolean().withDefault(const Constant(false))();

  // Control de registro
  TextColumn get estado => text().withDefault(const Constant('activo'))(); // activo / inactivo
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
