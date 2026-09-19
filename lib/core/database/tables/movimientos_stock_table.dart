import 'package:drift/drift.dart';
import 'lotes_table.dart';

/// Historial y auditoría inmutable del Kardex de inventario
class MovimientosStockTable extends Table {
  @override
  String get tableName => 'movimientos_stock';

  IntColumn get id => integer().autoIncrement()();
  // Tipos: entrada_compra, salida_venta, ajuste_positivo, ajuste_negativo, vencimiento, devolucion
  TextColumn get tipo => text()();
  IntColumn get loteId => integer().references(LotesTable, #id)();
  RealColumn get cantidad => real()();
  TextColumn get documentoReferencia => text().nullable()(); // Ej: Factura #001-001-000000123
  DateTimeColumn get fechaMovimiento => dateTime().withDefault(currentDateAndTime)();
  IntColumn get usuarioId => integer().nullable()();
  TextColumn get observaciones => text().nullable()();
}
