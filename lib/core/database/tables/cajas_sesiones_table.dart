import 'package:drift/drift.dart';

/// Control de turnos de caja, fondo inicial y arqueo ciego/físico
class CajasSesionesTable extends Table {
  @override
  String get tableName => 'cajas_sesiones';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get usuarioId => integer()();
  DateTimeColumn get fechaApertura => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get fechaCierre => dateTime().nullable()();

  // Apertura
  RealColumn get montoInicial => real().withDefault(const Constant(0.0))();

  // Cierre - Saldos del Sistema
  RealColumn get montoEsperadoEfectivo => real().withDefault(const Constant(0.0))();

  // Cierre - Arqueo Físico Declarado por el Cajero
  RealColumn get montoFinalEfectivo => real().nullable()();
  RealColumn get montoFinalTarjeta => real().nullable()();
  RealColumn get montoFinalTransferencia => real().nullable()();

  TextColumn get observaciones => text().nullable()();
  TextColumn get estado => text().withDefault(const Constant('abierta'))(); // abierta, cerrada
}
