import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_data_table.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/app_pagination_controls.dart';
import '../../../../shared/components/expiration_badge.dart';
import '../../../../shared/components/xela_badge.dart';
import '../../../../shared/components/xela_card.dart';
import '../../../../core/utils/debouncer.dart';
import '../../domain/entities/batch_stock.dart';
import '../controllers/inventory_notifier.dart';
import 'batch_entry_dialog.dart';
import 'batch_return_dialog.dart';

/// Pantalla de Gestión de Inventario, Lotes y Trazabilidad FEFO (Desktop High-Density)
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  @override
  void dispose() {
    _debouncer.dispose();
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
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.border),
          ),
          title: Row(
            children: [
              Icon(Icons.tune, color: colors.primary),
              const SizedBox(width: 8),
              Text('Ajustar Stock: Lote ${batch.lote}', style: TextStyle(fontSize: 16, color: colors.textPrimary)),
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
      );
    },
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

  void _onReturnBatch(BatchStock batch) async {
    final result = await BatchReturnDialog.show(context, batch);
    if (result != null && mounted) {
      final quantity = result['quantity'] as double;
      final reasonType = result['reasonType'] as String;
      final supplierId = result['supplierId'] as int?;
      final referenceDocument = result['referenceDocument'] as String?;
      final observations = result['observations'] as String?;

      final success = await ref.read(inventoryProvider.notifier).processMerchandiseReturn(
            batchId: batch.id!,
            quantity: quantity,
            reasonType: reasonType,
            supplierId: supplierId,
            referenceDocument: referenceDocument,
            observations: observations,
          );

      if (success && mounted) {
        AppSnackBars.showSuccess(
          context,
          message: 'Salida de inventario registrada con éxito.',
        );
        // Si fue cambio, sugerir ir a compras
        if (reasonType == 'cambio_proveedor') {
          // You could show an optional dialog here or just redirect
          AppSnackBars.showInfo(
            context,
            message: 'Navega a Compras para registrar el nuevo lote.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inventoryState = ref.watch(inventoryProvider);
    final batches = inventoryState.batches;
    final totalBatches = inventoryState.totalItems;
    final expiringSoonCount = inventoryState.expiringSoonCount;
    final expiredCount = inventoryState.expiredCount;
    final currentFilter = inventoryState.filter;
    final isLoading = inventoryState.isLoading;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): _onNewBatchEntry,
        const SingleActivator(LogicalKeyboardKey.f3): () => _searchFocusNode.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: colors.background,
          body: Column(
            children: [
              // Barra de Acciones de Inventario
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warehouse_outlined, color: colors.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Trazabilidad FEFO & Lotes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
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
                      value: totalBatches.toString(),
                      icon: Icons.inventory_2_outlined,
                      color: colors.primary,
                      colors: colors,
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      title: 'Próximos a Vencer (≤ 90 d)',
                      value: expiringSoonCount.toString(),
                      icon: Icons.access_time_outlined,
                      color: colors.warning,
                      colors: colors,
                      onTap: () => ref.read(inventoryProvider.notifier).setFilter(InventoryFilter.expiringSoon),
                    ),
                    const SizedBox(width: 16),
                    _buildKpiCard(
                      title: 'Lotes Caducados (Merma)',
                      value: expiredCount.toString(),
                      icon: Icons.error_outline,
                      color: colors.danger,
                      colors: colors,
                      onTap: () => ref.read(inventoryProvider.notifier).setFilter(InventoryFilter.expired),
                    ),
                  ],
                ),
              ),

              // Barra de Búsqueda y Filtros
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colors.cardBackground,
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
                        onChanged: (q) => _debouncer.run(() {
                          ref.read(inventoryProvider.notifier).setSearchQuery(q);
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 8,
                      children: InventoryFilter.values.map((f) {
                        final isSelected = currentFilter == f;
                        return ChoiceChip(
                          label: Text(f.label),
                          selected: isSelected,
                          onSelected: (_) => ref.read(inventoryProvider.notifier).setFilter(f),
                          selectedColor: colors.primarySurface,
                          backgroundColor: colors.background,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? colors.primaryText : colors.textPrimary,
                          ),
                          side: BorderSide(
                            color: isSelected ? colors.primary : colors.border,
                          ),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, thickness: 1, color: colors.border),

              // Tabla de Datos de Lotes
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : batches.isEmpty
                        ? _buildEmptyState(colors)
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: AppDataTable<BatchStock>(
                              data: batches,
                              paginationControls: AppPaginationControls(
                                currentPage: inventoryState.currentPage,
                                totalPages: inventoryState.totalPages,
                                totalItems: inventoryState.totalItems,
                                pageSize: inventoryState.pageSize,
                                onNextPage: () => ref.read(inventoryProvider.notifier).nextPage(),
                                onPreviousPage: () => ref.read(inventoryProvider.notifier).previousPage(),
                                onPageSizeChanged: (size) => ref.read(inventoryProvider.notifier).setPageSize(size),
                              ),
                              columns: [
                                AppTableColumn<BatchStock>(
                                  label: 'Nº Lote',
                                  width: 120,
                                  builder: (b) => Text(
                                    b.lote,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Medicamento',
                                  width: 200,
                                  builder: (b) => Text(
                                    b.productName ?? 'Sin asignar',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Presentación',
                                  width: 150,
                                  builder: (b) => Text(
                                    b.presentationName ?? 'General',
                                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
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
                                      color: b.stockActual <= 5 ? colors.danger : colors.textPrimary,
                                    ),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Costo Unit.',
                                  width: 100,
                                  numeric: true,
                                  builder: (b) => Text(
                                    AppFormatters.currency(b.precioCompraUnitario),
                                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Ubicación',
                                  width: 120,
                                  builder: (b) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.background,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Text(
                                      b.ubicacion ?? 'S/U',
                                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                                    ),
                                  ),
                                ),
                                AppTableColumn<BatchStock>(
                                  label: 'Acciones',
                                  width: 120,
                                  numeric: true,
                                  builder: (b) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.outbox_rounded, size: 18, color: colors.danger),
                                        tooltip: 'Registrar Salida / Devolución',
                                        onPressed: () => _onReturnBatch(b),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.tune, size: 18, color: colors.primary),
                                        tooltip: 'Ajustar Stock (Kardex)',
                                        onPressed: () => _onAdjustStock(b),
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
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required AppThemeColors colors,
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
                    style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500),
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

  Widget _buildEmptyState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warehouse_outlined, size: 64, color: colors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No hay lotes que coincidan con los filtros',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Use [F2] para registrar un ingreso de lote o cambie los filtros superiores.',
            style: TextStyle(fontSize: 13, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
