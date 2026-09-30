import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_dialogs.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../domain/entities/product.dart';
import '../controllers/product_catalog_notifier.dart';

class ProductMergeDialog extends ConsumerStatefulWidget {
  final Product targetProduct;

  const ProductMergeDialog({super.key, required this.targetProduct});

  static Future<bool?> show(BuildContext context, Product targetProduct) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductMergeDialog(targetProduct: targetProduct),
    );
  }

  @override
  ConsumerState<ProductMergeDialog> createState() => _ProductMergeDialogState();
}

class _ProductMergeDialogState extends ConsumerState<ProductMergeDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Product> _selectedDuplicates = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onConfirmMerge() async {
    if (_selectedDuplicates.isEmpty) {
      AppSnackBars.showError(context, message: 'Seleccione al menos un producto duplicado.');
      return;
    }

    final confirm = await AppConfirmDialog.show(
      context,
      title: 'Fusión Irreversible',
      message: 'Esta acción trasladará todo el stock y desactivará los productos seleccionados. ¿Está completamente seguro?',
      confirmText: 'Absorber Duplicados',
      isDestructive: true,
    );

    if (confirm != true) return;

    if (!mounted) return;

    final sourceIds = _selectedDuplicates.map((p) => p.id!).toList();
    final success = await ref.read(productCatalogProvider.notifier).unifyProducts(
          widget.targetProduct.id!,
          sourceIds,
        );

    if (!mounted) return;

    if (success) {
      AppSnackBars.showSuccess(context, message: 'Productos unificados correctamente.');
      Navigator.of(context).pop(true);
    } else {
      AppSnackBars.showError(context, message: 'Ocurrió un error al unificar los productos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(productCatalogProvider);
    
    // Filtramos productos activos que no sean el producto principal
    final availableProducts = catalogState.products.where((p) {
      if (p.id == widget.targetProduct.id) return false;
      if (p.estado != 'activo') return false;
      if (_searchQuery.isEmpty) return false;
      
      final q = _searchQuery.toLowerCase();
      return p.nombreComercial.toLowerCase().contains(q) || 
             (p.codigoBarras?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_merge, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Absorber Productos Duplicados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Producto Principal (Conservado):', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    widget.targetProduct.nombreComercial,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.info),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Este producto recibirá todos los lotes e historial de los duplicados que seleccione abajo.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _searchCtrl,
              label: 'Buscar Producto Duplicado (Nombre o Código)',
              prefixIcon: Icons.search,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
            const SizedBox(height: 12),
            if (_searchQuery.isNotEmpty)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: availableProducts.isEmpty
                    ? const Center(child: Text('No hay coincidencias.', style: TextStyle(color: AppColors.textMuted)))
                    : ListView.builder(
                        itemCount: availableProducts.length,
                        itemBuilder: (ctx, i) {
                          final p = availableProducts[i];
                          final isSelected = _selectedDuplicates.any((sel) => sel.id == p.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(p.nombreComercial, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text('ID: ${p.id} | Presentaciones: ${p.presentaciones.length}', style: const TextStyle(fontSize: 11)),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedDuplicates.add(p);
                                } else {
                                  _selectedDuplicates.removeWhere((sel) => sel.id == p.id);
                                }
                                _searchCtrl.clear();
                                _searchQuery = '';
                              });
                            },
                          );
                        },
                      ),
              ),
            if (_selectedDuplicates.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Duplicados Seleccionados para Absorber:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.danger)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedDuplicates.map((p) {
                  return Chip(
                    label: Text(p.nombreComercial, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedDuplicates.removeWhere((sel) => sel.id == p.id);
                      });
                    },
                    backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppSecondaryButton(
                  text: 'Cancelar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectedDuplicates.isEmpty ? null : _onConfirmMerge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.call_merge, size: 18),
                  label: const Text('Absorber Duplicados', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
