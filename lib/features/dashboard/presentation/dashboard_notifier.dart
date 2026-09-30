import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_models.dart';

// Proveedor para el estado general del Dashboard (Caducidades, Stock Bajo y Ventas Hoy)
final dashboardStateProvider = FutureProvider.autoDispose<DashboardState>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);

  // Ejecutamos las consultas en paralelo para mayor rapidez
  final resultados = await Future.wait([
    repository.getLotesPorCaducar(diasAlerta: 90),
    repository.getProductosStockBajo(),
    repository.getTotalVentasHoy(),
    repository.getGananciaHoy(),
    repository.getEstadisticasTicketsHoy(),
    repository.getCapitalInventario(),
    repository.getTopProductosMes(),
  ]);

  final ticketsStats = resultados[4] as (int, double);

  return DashboardState(
    lotesPorCaducar: resultados[0] as List<AlertaCaducidad>,
    productosStockBajo: resultados[1] as List<AlertaStock>,
    totalVentasHoy: resultados[2] as double,
    gananciaHoy: resultados[3] as double,
    ticketsHoy: ticketsStats.$1,
    ticketPromedio: ticketsStats.$2,
    capitalInventario: resultados[5] as double,
    topProductos: resultados[6] as List<ProductoTop>,
  );
});

class DashboardState {
  final List<AlertaCaducidad> lotesPorCaducar;
  final List<AlertaStock> productosStockBajo;
  final double totalVentasHoy;
  final double gananciaHoy;
  final int ticketsHoy;
  final double ticketPromedio;
  final double capitalInventario;
  final List<ProductoTop> topProductos;

  DashboardState({
    required this.lotesPorCaducar,
    required this.productosStockBajo,
    required this.totalVentasHoy,
    required this.gananciaHoy,
    required this.ticketsHoy,
    required this.ticketPromedio,
    required this.capitalInventario,
    required this.topProductos,
  });
}
