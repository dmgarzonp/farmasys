import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../dashboard_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(dashboardStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Alertas (Farmacia)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: \$err')),
        data: (data) {
          final moneyFormat = NumberFormat.currency(symbol: '\$');
          final dateFormat = DateFormat('dd/MM/yyyy');

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna Izquierda: Alertas Críticas (Caducidades)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta Resumen Ventas Hoy
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ventas de Hoy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(moneyFormat.format(data.totalVentasHoy), style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('🚨 Alertas de Caducidad (Próximos 90 días)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: data.lotesPorCaducar.isEmpty
                            ? const Center(child: Text('No hay productos próximos a caducar. ¡Excelente!'))
                            : ListView.builder(
                                itemCount: data.lotesPorCaducar.length,
                                itemBuilder: (context, index) {
                                  final alerta = data.lotesPorCaducar[index];
                                  final esCritico = alerta.diasRestantes <= 30;
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    color: esCritico ? Colors.red.shade50 : Colors.orange.shade50,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.warning_amber_rounded, 
                                        color: esCritico ? Colors.red : Colors.orange
                                      ),
                                      title: Text('\${alerta.productoNombre} (\${alerta.presentacionNombre})'),
                                      subtitle: Text('Lote: \${alerta.lote} - Stock: \${alerta.stockActual} unidades'),
                                      trailing: Text(
                                        'Vence: \${dateFormat.format(alerta.fechaVencimiento)}\n(\${alerta.diasRestantes} días)',
                                        style: TextStyle(
                                          color: esCritico ? Colors.red : Colors.orange.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Columna Derecha: Stock Bajo para Reposición
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📉 Stock Bajo (Sugerencia de Compra)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: data.productosStockBajo.isEmpty
                            ? const Center(child: Text('El inventario está saludable.'))
                            : ListView.builder(
                                itemCount: data.productosStockBajo.length,
                                itemBuilder: (context, index) {
                                  final alerta = data.productosStockBajo[index];
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: ListTile(
                                      leading: const Icon(Icons.trending_down_rounded, color: Colors.orange),
                                      title: Text('\${alerta.productoNombre}'),
                                      subtitle: Text('\${alerta.presentacionNombre}'),
                                      trailing: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Stock: \${alerta.stockTotal}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('Mínimo: \${alerta.stockMinimo}', style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
