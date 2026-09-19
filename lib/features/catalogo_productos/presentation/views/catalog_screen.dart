import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_data_table.dart';
import '../../../../shared/components/app_dialogs.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/xela_badge.dart';
import '../../domain/entities/product.dart';
import '../controllers/product_catalog_notifier.dart';
import 'product_form_dialog.dart';

/// Pantalla principal del Catálogo Maestro de Medicamentos y Productos (Desktop Ergonomic)
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onNewProduct() async {
    final newProduct = await ProductFormDialog.show(context);
    if (newProduct != null && mounted) {
      final success = await ref.read(productCatalogProvider.notifier).saveProduct(newProduct);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medicamento "${newProduct.nombreComercial}" registrado exitosamente.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _onEditProduct(Product product) async {
    final updated = await ProductFormDialog.show(context, product: product);
    if (updated != null && mounted) {
      final success = await ref.read(productCatalogProvider.notifier).saveProduct(updated);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medicamento "${updated.nombreComercial}" actualizado.'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    }
  }

  void _onToggleStatus(Product product) async {
    final actionText = product.isActive ? 'inactivar' : 'activar';
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '${actionText.toUpperCase()} Producto',
      message: '¿Está seguro de que desea $actionText el producto "${product.nombreComercial}"?',
      confirmText: actionText.toUpperCase(),
      isDestructive: product.isActive,
    );

    if (confirmed && mounted) {
      await ref.read(productCatalogProvider.notifier).toggleProductStatus(product.id!, !product.isActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(productCatalogProvider);
    final products = catalogState.filteredProducts;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): _onNewProduct,
        const SingleActivator(LogicalKeyboardKey.f3): () => _searchFocusNode.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Barra de Acciones de Catálogo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Catálogo Maestro de Productos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    XelaBadge(
                      text: '${products.length} ítems',
                      variant: XelaBadgeVariant.neutral,
                    ),
                    const Spacer(),
                    AppPrimaryButton(
                      text: 'Nuevo Medicamento',
                      shortcutLabel: 'F2',
                      icon: Icons.add_circle_outline,
                      onPressed: _onNewProduct,
                    ),
                  ],
                ),
              ),

              // Barra de Búsqueda y Filtros Rápidos (Desktop Filter Toolbar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: AppColors.cardBackground,
                child: Row(
                  children: [
                    // Buscador con atajo
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocusNode,
                        hintText: 'Buscar por nombre, principio activo, código [F3]...',
                        prefixIcon: Icons.search,
                        shortcutBadge: 'F3',
                        onChanged: (q) => ref.read(productCatalogProvider.notifier).setSearchQuery(q),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Chips de Filtros ARCSA
                    Wrap(
                      spacing: 8,
                      children: ProductCatalogFilter.values.map((f) {
                        final isSelected = catalogState.filter == f;
                        return ChoiceChip(
                          label: Text(f.label),
                          selected: isSelected,
                          onSelected: (_) => ref.read(productCatalogProvider.notifier).setFilter(f),
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

              // Mensaje de Error si existiera
              if (catalogState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.danger.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          catalogState.errorMessage!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tabla de Alta Densidad con la lista de productos
              Expanded(
                child: catalogState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? _buildEmptyState()
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: AppDataTable<Product>(
                              data: products,
                              columns: [
                                AppTableColumn<Product>(
                                  label: 'Código / Barras',
                                  width: 140,
                                  builder: (p) => Text(
                                    p.codigoBarras?.isNotEmpty == true ? p.codigoBarras! : 'S/C',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                AppTableColumn<Product>(
                                  label: 'Nombre Comercial',
                                  width: 200,
                                  builder: (p) => Text(
                                    p.nombreComercial,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppTableColumn<Product>(
                                  label: 'Principio Activo & Conc.',
                                  width: 180,
                                  builder: (p) => Text(
                                    [
                                      if (p.principioActivo != null) p.principioActivo,
                                      if (p.concentracion != null) p.concentracion,
                                    ].join(' - '),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppTableColumn<Product>(
                                  label: 'Presentación',
                                  width: 150,
                                  builder: (p) {
                                    final pres = p.presentaciones.isNotEmpty ? p.presentaciones.first : null;
                                    return Text(
                                      pres?.nombreDescriptivo ?? 'General',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                    );
                                  },
                                ),
                                AppTableColumn<Product>(
                                  label: 'PVP Caja',
                                  width: 100,
                                  numeric: true,
                                  builder: (p) {
                                    final pres = p.presentaciones.isNotEmpty ? p.presentaciones.first : null;
                                    return Text(
                                      AppFormatters.currency(pres?.precioVentaCaja ?? 0.0),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                                AppTableColumn<Product>(
                                  label: 'IVA',
                                  width: 80,
                                  builder: (p) {
                                    final tieneIva = p.presentaciones.isNotEmpty && p.presentaciones.first.tieneIva;
                                    return XelaBadge(
                                      text: tieneIva ? '12%' : '0%',
                                      variant: tieneIva ? XelaBadgeVariant.primary : XelaBadgeVariant.neutral,
                                    );
                                  },
                                ),
                                AppTableColumn<Product>(
                                  label: 'Regulación ARCSA',
                                  width: 220,
                                  builder: (p) => Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (p.requiereReceta)
                                        const XelaBadge(
                                          text: 'Receta',
                                          variant: XelaBadgeVariant.warning,
                                          icon: Icons.assignment_outlined,
                                        ),
                                      if (p.esAntibiotico)
                                        const XelaBadge(
                                          text: 'Antibiótico',
                                          variant: XelaBadgeVariant.info,
                                          icon: Icons.medication_outlined,
                                        ),
                                      if (p.esPsicotropico)
                                        const XelaBadge(
                                          text: 'Psicotrópico',
                                          variant: XelaBadgeVariant.danger,
                                          icon: Icons.warning_amber_rounded,
                                        ),
                                      if (!p.hasArcsaAlert)
                                        const Text('Venta Libre', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                AppTableColumn<Product>(
                                  label: 'Acciones',
                                  width: 100,
                                  numeric: true,
                                  builder: (p) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                        tooltip: 'Editar producto',
                                        onPressed: () => _onEditProduct(p),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          p.isActive ? Icons.toggle_on : Icons.toggle_off,
                                          size: 22,
                                          color: p.isActive ? AppColors.success : AppColors.textMuted,
                                        ),
                                        tooltip: p.isActive ? 'Inactivar' : 'Activar',
                                        onPressed: () => _onToggleStatus(p),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron medicamentos en el catálogo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comience registrando un nuevo medicamento con [F2] o modifique los filtros de búsqueda.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            text: 'Registrar Primer Medicamento',
            shortcutLabel: 'F2',
            icon: Icons.add_circle_outline,
            onPressed: _onNewProduct,
          ),
        ],
      ),
    );
  }
}
