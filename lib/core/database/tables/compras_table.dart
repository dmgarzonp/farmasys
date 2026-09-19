import 'package:drift/drift.dart';
import 'proveedores_table.dart';

/// Cabecera de facturas de compra y recepción de mercadería farmacéutica
class ComprasTable extends Table {
  @override
  String get tableName => 'compras';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get proveedorId => integer().references(ProveedoresTable, #id)();
  TextColumn get numeroFactura => text().withLength(min: 1, max: 25)(); // Ej: 001-001-000123456
  TextColumn get numeroAutorizacionSri => text().nullable()();
  DateTimeColumn get fechaEmision => dateTime()();
  DateTimeColumn get fechaRecepcion => dateTime().withDefault(currentDateAndTime)();

  // Totales financieros de la factura
  RealColumn get subtotalDoce => real().withDefault(const Constant(0.0))();
  RealColumn get subtotalCero => real().withDefault(const Constant(0.0))();
  RealColumn get iva => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();

  TextColumn get observaciones => text().nullable()();
  TextColumn get estado => text().withDefault(const Constant('ingresada'))(); // ingresada / anulada
}
