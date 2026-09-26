import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_data_table.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/expiration_badge.dart';
import '../../../../shared/components/xela_badge.dart';
import '../../../../shared/components/xela_card.dart';
import '../../domain/entities/batch_stock.dart';
import '../controllers/inventory_notifier.dart';
import 'batch_entry_dialog.dart';

/// Pantalla de Gestión de Inventario, Lotes y Trazabilidad FEFO (Desktop High-Density)
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onNewBatchEntry() async {
    final result = await BatchEntryDialog.show(context);
    if (result != null && mounted) {
      final batch = result['batch'] as BatchStock;
      final docRef = result['docRef'] as String?;

      final success = await ref.read(inventoryProvider.notifier).registerBatchEntry(
            batch,
            docRef: docRef,
            obs: 'Ingreso manual de mercadería',
          );

      if (success && mounted) {
        AppSnackBars.showSuccess(
          context,
          message: 'Lote "${batch.lote}" ingresado con ${batch.stockActual} unidades.',
        );
      }
    }
  }

  void _onAdjustStock(BatchStock batch) async {
    final newStockCtrl = TextEditingController(text: batch.stockActual.toString());
    final reasonCtrl = TextEditingController(text: 'Ajuste físico de inventario');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.tune, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Ajustar Stock: Lote ${batch.lote}', style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medicamento: ${batch.productName ?? 'Desconocido'}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            AppTextField(
              controller: newStockCtrl,
              label: 'Nuevo Stock Físico *',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: reasonCtrl,
              label: 'Motivo del Ajuste (Kardex) *',
              hintText: 'Ej: Conteo físico, Merma, Devolución...',
            ),
          ],
        ),
        actions: [
          AppSecondaryButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          AppPrimaryButton(
            text: 'Confirmar Ajuste',
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final newStock = double.tryParse(newStockCtrl.text);
      if (newStock != null && newStock >= 0) {
        final success = await ref.read(inventoryProvider.notifier).adjustStock(
              batch.id!,
              newStock,
              reasonCtrl.text.trim(),
            );
        if (success && mounted) {
          AppSnackBars.showInfo(
            context,
            message: 'Stock actualizado en Kardex.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);
    final batches = state.filteredBatches;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): _onNewBatchEntry,
        const SingleActivator(LogicalKeyboardKey.f3): () => _searchFocusNode.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Barra de Acciones de Inventario
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warehouse_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Trazabilidad FEFO & Lotes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 12),
                    XelaBadge(
                      text: '${batches.length} lotes',
                      variant: XelaBadgeVariant.neutral,
                    ),
                    const Spacer(),
                    AppPrimaryButton(
                      text: 'Ingresar Mercadería / Lote',
                      shortcutLabel: 'F2',
                      icon: Icons.add_box_outlined,
                      onPressed: _onNewBatchEntry,
                    ),
                  ],
                ),
              ),

              // Tarjetas Resumen de Indicadores Clave (KPIs)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildKpiCard(
                      title: 'Total Lotes Registrados',
                      value: state.totalBatches.toString(),
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      title: 'Próximos a Vencer (≤ 90 d)',
                      value: state.expiringSoonCount.toString(),
                      icon: Icons.access_time_outlined,
                      color: AppColors.warning,
                      onTap: () => ref.read(inventoryProvider.notifier).setFilter(InventoryFilter.expiringSoon),
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      title: 'Lotes Caducados (Merma)',
                      value: state.expiredCount.toString(),
                      icon: Icons.error_outline,
                      color: AppColors.danger,
                      onTap: () => ref.read(inventoryProvider.notifier).setFilter(InventoryFilter.expired),
                    ),
                  ],
                ),
              ),

              // Barra de Búsqueda y Filtros
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.cardBackground,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocusNode,
                        hintText: 'Buscar lote, medicamento o ubicación [F3]...',
                        prefixIcon: Icons.search,
                        shortcutBadge: 'F3',
                        onChanged: (q) => ref.read(inventoryProvider.notifier).setSearchQuery(q),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 8,
                      children: InventoryFilter.values.map((f) {
                        final isSelected = state.filter == f;
                        return ChoiceChip(
                          label: Text(f.label),
                          selected: isSelected,
                          onSelected: (_) => ref.read(inventoryProvider.notifier).setFilter(f),
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: AppColors.border),

              // Tabla de Datos de Lotes
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : batches.isEmpty
                        ? _buildEmptyState()
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: AppDataTable<BatchStock>(
                              data: batches,
                              columns: [
                                AppTableColumn<BatchStock>(
                                  label: 'Nº Lote',
                                  width: 120,
                                  builder: (b) => Text(
                                    b.lote,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Medicamento',
                                  width: 200,
                                  builder: (b) => Text(
                                    b.productName ?? 'Sin asignar',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Presentación',
                                  width: 150,
                                  builder: (b) => Text(
                                    b.presentationName ?? 'General',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Caducidad & Alerta',
                                  width: 150,
                                  builder: (b) => ExpirationBadge(expirationDate: b.fechaVencimiento),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Stock Actual',
                                  width: 100,
                                  numeric: true,
                                  builder: (b) => Text(
                                    b.stockActual.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: b.stockActual <= 5 ? AppColors.danger : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Costo Unit.',
                                  width: 100,
                                  numeric: true,
                                  builder: (b) => Text(
                                    AppFormatters.currency(b.precioCompraUnitario),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Ubicación',
                                  width: 120,
                                  builder: (b) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      b.ubicacion ?? 'S/U',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Acciones',
                                  width: 90,
                                  numeric: true,
                                  builder: (b) => IconButton(
                                    icon: const Icon(Icons.tune, size: 18, color: AppColors.primary),
                                    tooltip: 'Ajustar Stock (Kardex)',
                                    onPressed: () => _onAdjustStock(b),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: XelaCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warehouse_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'No hay lotes que coincidan con los filtros',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use [F2] para registrar un ingreso de lote o cambie los filtros superiores.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
