import 'package:drift/drift.dart';
import 'compras_table.dart';
import 'presentaciones_table.dart';

/// Detalle y renglones de recepción de mercadería con control técnico sanitario ARCSA
class DetallesCompraTable extends Table {
  @override
  String get tableName => 'detalles_compra';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get compraId => integer().references(ComprasTable, #id)();
  IntColumn get presentacionId => integer().references(PresentacionesTable, #id)();

  // Datos del lote físico del fabricante
  TextColumn get lote => text().withLength(min: 1, max: 50)();
  DateTimeColumn get fechaVencimiento => dateTime()();

  // Cantidades recibidas
  RealColumn get cantidadCajas => real().withDefault(const Constant(0.0))();
  RealColumn get cantidadUnidades => real().withDefault(const Constant(0.0))();

  // Costos de compra
  RealColumn get costoCaja => real().withDefault(const Constant(0.0))();
  RealColumn get costoUnitario => real().withDefault(const Constant(0.0))();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();

  // Verificación técnica sanitaria ARCSA
  BoolColumn get cumpleRegistroSanitario => boolean().withDefault(const Constant(true))();
  BoolColumn get cumpleEmpaque => boolean().withDefault(const Constant(true))();
  RealColumn get temperaturaRecepcion => real().nullable()(); // Cadena de frío (2°C - 8°C)
}
