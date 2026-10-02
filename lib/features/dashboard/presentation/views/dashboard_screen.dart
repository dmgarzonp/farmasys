import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../dashboard_notifier.dart';
import '../../../inventario/data/repositories/drift_inventory_repository.dart';
import '../../../inventario/presentation/controllers/inventory_notifier.dart';
import '../../../inventario/presentation/views/batch_return_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(dashboardStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Farmacia'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final moneyFormat = NumberFormat.currency(symbol: '\$');
          final dateFormat = DateFormat('dd/MM/yyyy');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila 1: KPIs Principales
                Row(
                  children: [
                    _buildKpiCard(
                      title: 'Ventas de Hoy',
                      value: moneyFormat.format(data.totalVentasHoy),
                      icon: Icons.point_of_sale,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      title: 'Ganancia (Utilidad)',
                      value: moneyFormat.format(data.gananciaHoy),
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      title: 'Tickets Hoy',
                      value: data.ticketsHoy.toString(),
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      title: 'Ticket Promedio',
                      value: moneyFormat.format(data.ticketPromedio),
                      icon: Icons.analytics,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fila 2: Top Productos y Capital Invertido
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text('Top 5 Productos (Mes Actual)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              data.topProductos.isEmpty 
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('Aún no hay ventas registradas en los últimos 30 días.'),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: data.topProductos.length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final p = data.topProductos[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue.shade50,
                                          child: Text('${index + 1}', style: const TextStyle(color: Colors.blue)),
                                        ),
                                        title: Text(p.productoNombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Text(p.presentacionNombre),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('${p.cantidadVendida.toInt()} vendidos', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text(moneyFormat.format(p.totalRecaudado), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 2,
                        color: Colors.indigo.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Icon(Icons.inventory_2, size: 48, color: Colors.indigo),
                              const SizedBox(height: 16),
                              const Text('Capital en Inventario', style: TextStyle(fontSize: 16, color: Colors.indigo)),
                              const SizedBox(height: 8),
                              Text(
                                moneyFormat.format(data.capitalInventario),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                              const SizedBox(height: 8),
                              const Text('Valorizado a precio de costo', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fila 3: Alertas de Stock y Caducidad
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alertas de Caducidad
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🚨 Alertas de Caducidad (Próx. 90 días)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          data.lotesPorCaducar.isEmpty
                              ? const Center(child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No hay productos próximos a caducar. ¡Excelente!'),
                              ))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: data.lotesPorCaducar.length,
                                  itemBuilder: (context, index) {
                                    final alerta = data.lotesPorCaducar[index];
                                    final esCritico = alerta.diasRestantes <= 30;
                                    
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8.0),
                                      color: esCritico ? Colors.red.shade50 : Colors.orange.shade50,
                                      child: InkWell(
                                        onTap: () async {
                                          final inventoryRepo = ref.read(inventoryRepositoryProvider);
                                          final batch = await inventoryRepo.getBatchById(alerta.loteId);
                                          if (batch == null || !context.mounted) return;
                                          
                                          final result = await BatchReturnDialog.show(context, batch);
                                          if (result != null && context.mounted) {
                                            final quantity = result['quantity'] as double;
                                            final reasonType = result['reasonType'] as String;
                                            
                                            final success = await ref.read(inventoryProvider.notifier).processMerchandiseReturn(
                                                  batchId: batch.id!,
                                                  quantity: quantity,
                                                  reasonType: reasonType,
                                                  supplierId: result['supplierId'] as int?,
                                                  referenceDocument: result['referenceDocument'] as String?,
                                                  observations: result['observations'] as String?,
                                                );

                                            if (success && context.mounted) {
                                              ref.invalidate(dashboardStateProvider);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Salida/Devolución procesada con éxito')),
                                              );
                                            }
                                          }
                                        },
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.warning_amber_rounded, 
                                            color: esCritico ? Colors.red : Colors.orange
                                          ),
                                          title: Text('${alerta.productoNombre} (${alerta.presentacionNombre})'),
                                          subtitle: Text('Lote: ${alerta.lote} - Stock: ${alerta.stockActual} u.\nTap para devolver/descartar'),
                                          trailing: Text(
                                            'Vence: ${dateFormat.format(alerta.fechaVencimiento)}\n(${alerta.diasRestantes} días)',
                                            style: TextStyle(
                                              color: esCritico ? Colors.red : Colors.orange.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Alertas Stock Bajo
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📉 Stock Bajo (Sugerencia de Compra)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          data.productosStockBajo.isEmpty
                              ? const Center(child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('El inventario está saludable.'),
                              ))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: data.productosStockBajo.length,
                                  itemBuilder: (context, index) {
                                    final alerta = data.productosStockBajo[index];
                                    
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8.0),
                                      child: ListTile(
                                        leading: const Icon(Icons.trending_down_rounded, color: Colors.orange),
                                        title: Text(alerta.productoNombre),
                                        subtitle: Text(alerta.presentacionNombre),
                                        trailing: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Stock: ${alerta.stockTotal}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text('Mínimo: ${alerta.stockMinimo}', style: const TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required MaterialColor color}) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.shade50,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
