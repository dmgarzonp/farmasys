import 'package:drift/drift.dart';
import 'ventas_table.dart';
import 'presentaciones_table.dart';
import 'lotes_table.dart';

/// Detalle de renglones de venta vinculados al lote de donde se despachó el medicamento
class DetallesVentaTable extends Table {
  @override
  String get tableName => 'detalles_venta';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get ventaId => integer().references(VentasTable, #id)();
  IntColumn get presentacionId => integer().references(PresentacionesTable, #id)();
  IntColumn get loteId => integer().references(LotesTable, #id)();

  RealColumn get cantidad => real()();
  BoolColumn get esFraccion => boolean().withDefault(const Constant(false))();

  RealColumn get precioUnitario => real()();
  RealColumn get descuento => real().withDefault(const Constant(0.0))();
  RealColumn get subtotal => real()();
  RealColumn get ivaTotal => real().withDefault(const Constant(0.0))();
}
