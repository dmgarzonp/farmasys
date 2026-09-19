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
  ]);

  return DashboardState(
    lotesPorCaducar: resultados[0] as List<AlertaCaducidad>,
    productosStockBajo: resultados[1] as List<AlertaStock>,
    totalVentasHoy: resultados[2] as double,
  );
});

class DashboardState {
  final List<AlertaCaducidad> lotesPorCaducar;
  final List<AlertaStock> productosStockBajo;
  final double totalVentasHoy;

  DashboardState({
    required this.lotesPorCaducar,
    required this.productosStockBajo,
    required this.totalVentasHoy,
  });
}
