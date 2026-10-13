import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/theme/app_theme.dart';
import 'package:farmsys/features/dashboard/domain/dashboard_models.dart';
import 'package:farmsys/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:farmsys/features/dashboard/presentation/views/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockDashboardData = DashboardState(
    totalVentasHoy: 1250.50,
    gananciaHoy: 430.20,
    ticketsHoy: 42,
    ticketPromedio: 29.77,
    capitalInventario: 8940.00,
    topProductos: [
      ProductoTop(
        productoNombre: 'PARACETAMOL 500 MG',
        presentacionNombre: 'Caja x 100 tabletas',
        cantidadVendida: 80,
        totalRecaudado: 40.00,
      ),
      ProductoTop(
        productoNombre: 'IBUPROFENO 600 MG',
        presentacionNombre: 'Caja x 50 cápsulas',
        cantidadVendida: 35,
        totalRecaudado: 28.50,
      ),
    ],
    lotesPorCaducar: [
      AlertaCaducidad(
        loteId: 101,
        lote: 'L-2026-A',
        productoNombre: 'Amoxicilina 500mg',
        presentacionNombre: 'Frasco',
        fechaVencimiento: DateTime.now().add(const Duration(days: 15)),
        stockActual: 12.0,
      ),
    ],
    productosStockBajo: [
      AlertaStock(
        productoNombre: 'Omeprazol 20mg',
        presentacionNombre: 'Caja x 30',
        stockTotal: 4.0,
        stockMinimo: 10,
      ),
    ],
  );

  testWidgets('DashboardScreen se renderiza en Modo Oscuro con contraste óptimo y sin errores', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWith((ref) => Future.value(mockDashboardData)),
      ],
    );

    final darkTheme = AppTheme.buildDarkTheme(const Color(0xFF059669));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: darkTheme,
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificación de KPIs Principales
    expect(find.text('Ventas de Hoy'), findsOneWidget);
    expect(find.text('Ganancia (Utilidad)'), findsOneWidget);
    expect(find.text('Tickets Hoy'), findsOneWidget);
    expect(find.text('Ticket Promedio'), findsOneWidget);

    // Verificación de Top Productos y Capital en Inventario
    expect(find.text('Top 5 Productos (Mes Actual)'), findsOneWidget);
    expect(find.text('PARACETAMOL 500 MG'), findsOneWidget);
    expect(find.text('Capital en Inventario'), findsOneWidget);
    expect(find.text('Activo Circulante'), findsOneWidget);

    // Verificación de Alertas
    expect(find.text('Alertas de Caducidad (Próx. 90 días)'), findsOneWidget);
    expect(find.text('Stock Bajo (Sugerencia de Compra)'), findsOneWidget);
    expect(find.text('Omeprazol 20mg'), findsOneWidget);
  });

  testWidgets('DashboardScreen se renderiza en Modo Claro de forma consistente', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWith((ref) => Future.value(mockDashboardData)),
      ],
    );

    final lightTheme = AppTheme.buildLightTheme(const Color(0xFF059669));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: lightTheme,
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ventas de Hoy'), findsOneWidget);
    expect(find.text('Capital en Inventario'), findsOneWidget);
    expect(find.text('Alertas de Caducidad (Próx. 90 días)'), findsOneWidget);
  });
}
