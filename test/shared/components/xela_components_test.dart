import 'package:farmsys/features/caja/data/repositories/drift_cash_session_repository.dart';
import 'package:farmsys/features/caja/domain/entities/cash_session.dart';
import 'package:farmsys/features/caja/domain/repositories/i_cash_session_repository.dart';
import 'package:farmsys/shared/components/xela_badge.dart';
import 'package:farmsys/shared/components/xela_card.dart';
import 'package:farmsys/shared/components/xela_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCashSessionRepository implements ICashSessionRepository {
  @override
  Future<CashSession> openSession({
    required int usuarioId,
    required double montoInicial,
    String? observaciones,
  }) async {
    return CashSession(
      id: 1,
      usuarioId: usuarioId,
      fechaApertura: DateTime.now(),
      montoInicial: montoInicial,
      estado: 'abierta',
    );
  }

  @override
  Future<CashSession> closeSession({
    required int sessionId,
    required double montoFinalEfectivo,
    double? montoFinalTarjeta,
    double? montoFinalTransferencia,
    String? observaciones,
  }) async {
    return CashSession(
      id: sessionId,
      usuarioId: 1,
      fechaApertura: DateTime.now(),
      montoInicial: 50.0,
      estado: 'cerrada',
    );
  }

  @override
  Future<CashSession?> getActiveSession({int? usuarioId}) async => null;

  @override
  Stream<CashSession?> watchActiveSession({int? usuarioId}) => Stream.value(null);

  @override
  Future<void> addCashSale(int sessionId, double amount) async {}
}

void main() {
  group('Xela UI Kit - Componentes Visuales', () {
    testWidgets('XelaBadge renderiza texto, variante y estilo tipo píldora', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                XelaBadge(
                  text: 'Receta Médica',
                  variant: XelaBadgeVariant.danger,
                  icon: Icons.assignment_late_outlined,
                ),
                XelaBadge(
                  text: 'SRI 12% Activo',
                  variant: XelaBadgeVariant.success,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Receta Médica'), findsOneWidget);
      expect(find.text('SRI 12% Activo'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_late_outlined), findsOneWidget);
    });

    testWidgets('XelaCard renderiza contenido y responde a toques', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XelaCard(
              onTap: () => tapped = true,
              child: const Text('Tarjeta Modular Xela'),
            ),
          ),
        ),
      );

      expect(find.text('Tarjeta Modular Xela'), findsOneWidget);
      await tester.tap(find.text('Tarjeta Modular Xela'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('XelaSidebar renderiza accesos directos y atajos F1, F4, F5, F9', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cashSessionRepositoryProvider.overrideWithValue(MockCashSessionRepository()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: XelaSidebar(
                currentLocation: '/',
                onOpenCash: () {},
                onCloseCash: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Punto de Venta'), findsOneWidget);
      expect(find.text('Catálogo Maestro'), findsOneWidget);
      expect(find.text('Inventario FEFO'), findsOneWidget);
      expect(find.text('Recepción Compras'), findsOneWidget);
      expect(find.text('F1'), findsOneWidget);
      expect(find.text('F4'), findsOneWidget);
      expect(find.text('F5'), findsOneWidget);
      expect(find.text('F9'), findsOneWidget);
    });
  });
}
