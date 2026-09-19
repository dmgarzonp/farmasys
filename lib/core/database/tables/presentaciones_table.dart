import 'package:drift/drift.dart';
import 'productos_table.dart';

/// Define cómo se comercializa el producto (caja, blíster, frasco, unidad)
class PresentacionesTable extends Table {
  @override
  String get tableName => 'presentaciones';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get productoId => integer().references(ProductosTable, #id)();
  TextColumn get nombreDescriptivo => text().withLength(min: 1, max: 100)(); // Ej: "Caja x 30 tabletas"
  IntColumn get unidadesPorCaja => integer().withDefault(const Constant(1))();

  // Precios y costos
  RealColumn get precioCompraCaja => real().withDefault(const Constant(0.0))();
  RealColumn get precioVentaCaja => real().withDefault(const Constant(0.0))();
  RealColumn get precioVentaFraccion => real().withDefault(const Constant(0.0))(); // Venta suelta/blíster

  // Inventario y código
  IntColumn get stockMinimo => integer().withDefault(const Constant(5))();
  TextColumn get codigoBarras => text().nullable()();
  BoolColumn get tieneIva => boolean().withDefault(const Constant(false))(); // false = 0%, true = 15%
}
