import 'package:drift/drift.dart';

/// Registro de ventas y facturas emitidas
class VentasTable extends Table {
  @override
  String get tableName => 'ventas';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().nullable()();
  IntColumn get usuarioId => integer()();
  IntColumn get sesionCajaId => integer()();

  DateTimeColumn get fechaVenta => dateTime().withDefault(currentDateAndTime)();

  // Desglose financiero
  RealColumn get subtotal0 => real().withDefault(const Constant(0.0))();
  RealColumn get subtotal15 => real().withDefault(const Constant(0.0))();
  RealColumn get descuentoTotal => real().withDefault(const Constant(0.0))();
  RealColumn get impuestoTotal => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();

  // Pago
  TextColumn get metodoPago => text().withDefault(const Constant('efectivo'))();

  // Datos de Facturación Electrónica SRI
  TextColumn get claveAcceso => text().nullable()();
  TextColumn get estadoSri => text().withDefault(const Constant('pendiente'))(); // pendiente, autorizado, rechazado
  TextColumn get mensajeSri => text().nullable()();
}
