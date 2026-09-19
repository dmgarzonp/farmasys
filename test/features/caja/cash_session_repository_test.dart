import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/features/caja/data/repositories/drift_cash_session_repository.dart';
import 'package:farmsys/features/caja/domain/repositories/i_cash_session_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  late AppDatabase database;
  late ICashSessionRepository cashRepo;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      try {
        return DynamicLibrary.open('libsqlite3.so');
      } catch (_) {
        return DynamicLibrary.open('libsqlite3.so.0');
      }
    });
  });

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    cashRepo = DriftCashSessionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftCashSessionRepository - Control de Turnos y Arqueo (SOLID: DIP)', () {
    test('Abre un turno con fondo inicial y lo consulta como sesión activa', () async {
      final initialActive = await cashRepo.getActiveSession();
      expect(initialActive, isNull);

      final session = await cashRepo.openSession(
        usuarioId: 1,
        montoInicial: 60.0,
        observaciones: 'Apertura turno matutino',
      );

      expect(session.id, greaterThan(0));
      expect(session.montoInicial, equals(60.0));
      expect(session.montoEsperadoEfectivo, equals(0.0));
      expect(session.isOpen, isTrue);

      final active = await cashRepo.getActiveSession();
      expect(active, isNotNull);
      expect(active!.id, equals(session.id));
      expect(active.montoInicial, equals(60.0));
    });

    test('Lanza StateError al intentar abrir un segundo turno si ya hay uno activo', () async {
      await cashRepo.openSession(usuarioId: 1, montoInicial: 50.0);

      expect(
        () => cashRepo.openSession(usuarioId: 1, montoInicial: 30.0),
        throwsA(isA<StateError>()),
      );
    });

    test('addCashSale incrementa el monto esperado de efectivo en la sesión', () async {
      final session = await cashRepo.openSession(usuarioId: 1, montoInicial: 40.0);

      await cashRepo.addCashSale(session.id!, 25.50);
      await cashRepo.addCashSale(session.id!, 14.50);

      final updated = await cashRepo.getActiveSession();
      expect(updated!.montoEsperadoEfectivo, equals(40.0)); // 25.50 + 14.50 = 40.0
    });

    test('Cierra el turno de caja y calcula diferencias de arqueo', () async {
      final session = await cashRepo.openSession(usuarioId: 1, montoInicial: 50.0);
      await cashRepo.addCashSale(session.id!, 100.0); // Esperado: 50 inicial + 100 venta = 150

      // El cajero declara 152 en efectivo ($2 de sobrante) y $30 en tarjeta
      final closed = await cashRepo.closeSession(
        sessionId: session.id!,
        montoFinalEfectivo: 152.0,
        montoFinalTarjeta: 30.0,
        observaciones: 'Cierre sin novedades',
      );

      expect(closed.isClosed, isTrue);
      expect(closed.montoFinalEfectivo, equals(152.0));
      expect(closed.cashDifference, equals(2.0)); // 152 - 150 = +2.0

      // Ya no debe haber sesión activa
      final active = await cashRepo.getActiveSession();
      expect(active, isNull);
    });
  });
}
