import 'package:drift/drift.dart';
import 'presentaciones_table.dart';

/// Almacena el inventario físico con trazabilidad de lote y vencimiento (FEFO)
class LotesTable extends Table {
  @override
  String get tableName => 'lotes';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get presentacionId => integer().references(PresentacionesTable, #id)();
  TextColumn get lote => text().withLength(min: 1, max: 50)();
  DateTimeColumn get fechaVencimiento => dateTime()();
  DateTimeColumn get fechaIngreso => dateTime().withDefault(currentDateAndTime)();

  // Stock físico en unidades mínimas (tabletas/frascos)
  RealColumn get stockActual => real().withDefault(const Constant(0.0))();
  RealColumn get precioCompraCaja => real().withDefault(const Constant(0.0))();
  RealColumn get precioCompraUnitario => real().withDefault(const Constant(0.0))();

  // Ubicación en farmacia (ej: Estante A, Gaveta 3, Refrigerado)
  TextColumn get ubicacion => text().nullable()();
}
