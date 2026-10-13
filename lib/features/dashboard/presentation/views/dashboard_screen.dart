import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/components/components.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../../inventario/data/repositories/drift_inventory_repository.dart';
import '../../../inventario/presentation/controllers/inventory_notifier.dart';
import '../../../inventario/presentation/views/batch_return_dialog.dart';
import '../dashboard_notifier.dart';

/// Pantalla del Dashboard Principal de FarmSys con métricas en tiempo real,
/// alertas de caducidad FEFO, stock bajo y top de ventas.
/// Totalmente adaptada a los modos Claro, Oscuro y de Sistema con paleta Slate.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDark;
    final stateAsync = ref.watch(dashboardStateProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: stateAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
        error: (err, stack) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.danger.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: colors.danger),
                const SizedBox(height: 12),
                Text(
                  'Error al cargar indicadores',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
                      context: context,
                      colors: colors,
                      title: 'Ventas de Hoy',
                      value: moneyFormat.format(data.totalVentasHoy),
                      icon: Icons.point_of_sale_rounded,
                      iconColor: colors.primary,
                      badgeText: 'Día Actual',
                      badgeVariant: XelaBadgeVariant.success,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      context: context,
                      colors: colors,
                      title: 'Ganancia (Utilidad)',
                      value: moneyFormat.format(data.gananciaHoy),
                      icon: Icons.trending_up_rounded,
                      iconColor: const Color(0xFF059669),
                      badgeText: 'Margen Neto',
                      badgeVariant: XelaBadgeVariant.primary,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      context: context,
                      colors: colors,
                      title: 'Tickets Hoy',
                      value: data.ticketsHoy.toString(),
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      badgeText: 'Comprobantes',
                      badgeVariant: XelaBadgeVariant.warning,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      context: context,
                      colors: colors,
                      title: 'Ticket Promedio',
                      value: moneyFormat.format(data.ticketPromedio),
                      icon: Icons.analytics_rounded,
                      iconColor: const Color(0xFF6366F1),
                      badgeText: 'Prom./Ticket',
                      badgeVariant: XelaBadgeVariant.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fila 2: Top Productos y Capital Invertido
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top 5 Productos (Mes Actual)
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: isDark ? 0.20 : 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Top 5 Productos (Mes Actual)',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: colors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const XelaBadge(
                                  text: 'Mayor Demanda',
                                  variant: XelaBadgeVariant.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (data.topProductos.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32.0),
                                child: Center(
                                  child: Text(
                                    'Aún no hay ventas registradas en los últimos 30 días.',
                                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.topProductos.length,
                                separatorBuilder: (context, index) => Divider(color: colors.border, height: 1),
                                itemBuilder: (context, index) {
                                  final p = data.topProductos[index];
                                  final rankStyle = _getRankColors(index, colors, isDark);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: rankStyle.bg,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: rankStyle.border, width: 1),
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: rankStyle.text,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.productoNombre,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textPrimary,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                p.presentacionNombre,
                                                style: TextStyle(
                                                  color: colors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${p.cantidadVendida.toInt()} vendidos',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: colors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              moneyFormat.format(p.totalRecaudado),
                                              style: TextStyle(
                                                color: colors.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Capital en Inventario
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(22.0),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? colors.secondary.withValues(alpha: 0.35) : colors.border,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.secondaryLight.withValues(alpha: isDark ? 0.20 : 0.10),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colors.secondaryLight.withValues(alpha: isDark ? 0.35 : 0.20),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 24,
                                    color: colors.secondaryLight,
                                  ),
                                ),
                                const XelaBadge(
                                  text: 'Activo Circulante',
                                  variant: XelaBadgeVariant.purple,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Capital en Inventario',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              moneyFormat.format(data.capitalInventario),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Divider(color: colors.border, height: 1),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 16, color: colors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Valorizado a costo neto de adquisición según catálogo y compras',
                                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                    // Columna 1: Alertas de Caducidad
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: colors.danger.withValues(alpha: isDark ? 0.20 : 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.alarm_on_rounded, size: 18, color: colors.danger),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Alertas de Caducidad (Próx. 90 días)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: colors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (data.lotesPorCaducar.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                XelaBadge(
                                  text: '${data.lotesPorCaducar.length} Lotes',
                                  variant: XelaBadgeVariant.danger,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (data.lotesPorCaducar.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No hay lotes próximos a caducar. ¡Excelente!',
                                    style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.lotesPorCaducar.length,
                              itemBuilder: (context, index) {
                                final alerta = data.lotesPorCaducar[index];
                                final esCritico = alerta.diasRestantes <= 30;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: esCritico
                                          ? colors.danger.withValues(alpha: isDark ? 0.40 : 0.30)
                                          : colors.warning.withValues(alpha: isDark ? 0.40 : 0.30),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
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
                                            AppSnackBars.showSuccess(
                                              context,
                                              message: 'Salida/Devolución procesada con éxito.',
                                            );
                                          }
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: (esCritico ? colors.danger : colors.warning).withValues(alpha: isDark ? 0.20 : 0.12),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.warning_amber_rounded,
                                                color: esCritico ? colors.danger : colors.warning,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${alerta.productoNombre} (${alerta.presentacionNombre})',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: colors.textPrimary,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Lote: ${alerta.lote} • Stock: ${alerta.stockActual.toInt()} u.',
                                                    style: TextStyle(
                                                      color: colors.textSecondary,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Click para devolver o descartar',
                                                    style: TextStyle(
                                                      color: colors.textMuted,
                                                      fontSize: 10,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                ExpirationBadge(
                                                  expirationDate: alerta.fechaVencimiento,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Vence: ${dateFormat.format(alerta.fechaVencimiento)}',
                                                  style: TextStyle(
                                                    color: colors.textSecondary,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
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

                    // Columna 2: Alertas Stock Bajo
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: colors.warning.withValues(alpha: isDark ? 0.20 : 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.trending_down_rounded, size: 18, color: colors.warning),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Stock Bajo (Sugerencia de Compra)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: colors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (data.productosStockBajo.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                XelaBadge(
                                  text: '${data.productosStockBajo.length} Ítems',
                                  variant: XelaBadgeVariant.warning,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (data.productosStockBajo.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_outlined, color: colors.success, size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    'El inventario se encuentra en niveles saludables.',
                                    style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.productosStockBajo.length,
                              itemBuilder: (context, index) {
                                final alerta = data.productosStockBajo[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: colors.cardBackground,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.border, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colors.warning.withValues(alpha: isDark ? 0.20 : 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.inventory_rounded, color: colors.warning, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              alerta.productoNombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: colors.textPrimary,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              alerta.presentacionNombre,
                                              style: TextStyle(
                                                color: colors.textSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          XelaBadge(
                                            text: 'Stock: ${alerta.stockTotal.toInt()}',
                                            variant: XelaBadgeVariant.danger,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mínimo: ${alerta.stockMinimo.toInt()}',
                                            style: TextStyle(
                                              color: colors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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

  /// Construye una tarjeta KPI con estilo uniforme y contraste adaptativo según el tema activo
  Widget _buildKpiCard({
    required BuildContext context,
    required AppThemeColors colors,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required XelaBadgeVariant badgeVariant,
  }) {
    final isDark = context.isDark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconColor.withValues(alpha: isDark ? 0.35 : 0.20),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                XelaBadge(
                  text: badgeText,
                  variant: badgeVariant,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Estilo diferenciado para los ranks de productos más vendidos
  ({Color bg, Color text, Color border}) _getRankColors(int index, AppThemeColors colors, bool isDark) {
    if (index == 0) {
      // Oro (#1)
      return (
        bg: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.12),
        text: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
        border: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.45 : 0.25),
      );
    } else if (index == 1) {
      // Plata (#2)
      return (
        bg: const Color(0xFF94A3B8).withValues(alpha: isDark ? 0.22 : 0.12),
        text: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
        border: const Color(0xFF94A3B8).withValues(alpha: isDark ? 0.45 : 0.25),
      );
    } else if (index == 2) {
      // Bronce (#3)
      return (
        bg: const Color(0xFFD97706).withValues(alpha: isDark ? 0.22 : 0.12),
        text: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309),
        border: const Color(0xFFD97706).withValues(alpha: isDark ? 0.45 : 0.25),
      );
    } else {
      // Otros (#4, #5)
      return (
        bg: colors.background,
        text: colors.textSecondary,
        border: colors.border,
      );
    }
  }
}
