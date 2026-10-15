import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/theme_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_data_table.dart';
import '../../../../shared/components/app_dialogs.dart';
import '../../../../shared/components/app_pagination_controls.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/xela_badge.dart';
import '../../../../core/utils/debouncer.dart';
import '../controllers/product_catalog_notifier.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';
import '../../../inventario/presentation/controllers/inventory_notifier.dart';
import '../../domain/entities/product.dart';
import 'product_form_dialog.dart';
import 'product_merge_dialog.dart';
import 'catalog_import_dialog.dart';

/// Pantalla principal del Catálogo Maestro de Medicamentos y Productos (Desktop Ergonomic)
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
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

  void _onNewProduct() async {
    final newProduct = await ProductFormDialog.show(context);
    if (newProduct != null && mounted) {
      final success = await ref.read(productCatalogProvider.notifier).saveProduct(newProduct);
      if (success && mounted) {
        AppSnackBars.showSuccess(
          context,
          message: 'Medicamento "${newProduct.nombreComercial}" registrado exitosamente.',
        );
      }
    }
  }

  void _onEditProduct(Product product) async {
    final updated = await ProductFormDialog.show(context, product: product);
    if (updated != null && mounted) {
      final success = await ref.read(productCatalogProvider.notifier).saveProduct(updated);
      if (success && mounted) {
        AppSnackBars.showInfo(
          context,
          message: 'Medicamento "${updated.nombreComercial}" actualizado.',
        );
      }
    }
  }

  void _onToggleStatus(Product product, Map<int, double> stockMap) async {
    final actionText = product.isActive ? 'inactivar' : 'activar';
    
    double totalStock = 0;
    for (var pres in product.presentaciones) {
      totalStock += stockMap[pres.id!] ?? 0;
    }

    String extraWarning = '';
    if (product.isActive && totalStock > 0) {
      extraWarning = '\n\n⚠️ ADVERTENCIA: Este producto tiene ${totalStock.toInt()} unidades en stock. Si lo inactiva, no podrá venderlo en el Punto de Venta.';
    }

    final confirmed = await AppConfirmDialog.show(
      context,
      title: '${actionText.toUpperCase()} Producto',
      message: '¿Está seguro de que desea $actionText el producto "${product.nombreComercial}"?$extraWarning',
      confirmText: actionText.toUpperCase(),
      isDestructive: product.isActive,
    );

    if (confirmed && mounted) {
      await ref.read(productCatalogProvider.notifier).toggleProductStatus(product.id!, !product.isActive);
    }
  }

  void _onMergeProduct(Product product) async {
    final merged = await ProductMergeDialog.show(context, product);
    if (merged == true) {
      // Opcionalmente hacer algo tras el merge, el notifier ya recargó la lista
    }
  }

  void _onImportCatalog() async {
    final result = await CatalogImportDialog.show(context);
    if (result == true && mounted) {
      await ref.read(productCatalogProvider.notifier).loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catalogState = ref.watch(productCatalogProvider);
    final products = catalogState.products;
    final currentFilter = catalogState.filter;
    final isLoading = catalogState.isLoading;
    final errorMessage = catalogState.errorMessage;
    final stockMap = ref.watch(availableStockMapProvider).value ?? {};

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): _onNewProduct,
        const SingleActivator(LogicalKeyboardKey.f3): () => _searchFocusNode.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: colors.background,
          body: Column(
            children: [
              // Barra de Acciones de Catálogo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: colors.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Catálogo Maestro de Productos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    XelaBadge(
                      text: '${products.length} ítems',
                      variant: XelaBadgeVariant.neutral,
                    ),
                    const Spacer(),
                    AppSecondaryButton(
                      text: 'Importar Excel / CSV',
                      icon: Icons.file_upload_outlined,
                      onPressed: _onImportCatalog,
                    ),
                    const SizedBox(width: 10),
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
                color: colors.cardBackground,
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
                        onChanged: (q) => _debouncer.run(() {
                          ref.read(productCatalogProvider.notifier).setSearchQuery(q);
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Chips de Filtros ARCSA
                    Wrap(
                      spacing: 8,
                      children: ProductCatalogFilter.values.map((f) {
                        final isSelected = currentFilter == f;
                        return ChoiceChip(
                          label: Text(f.label),
                          selected: isSelected,
                          onSelected: (_) => ref.read(productCatalogProvider.notifier).setFilter(f),
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

              // Mensaje de Error si existiera
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: colors.danger.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: colors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tabla de Alta Densidad con la lista de productos
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? _buildEmptyState(colors)
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: AppDataTable<Product>(
                              tableKey: 'catalog_products_table',
                              data: products,
                              paginationControls: AppPaginationControls(
                                currentPage: catalogState.currentPage,
                                totalPages: catalogState.totalPages,
                                totalItems: catalogState.totalItems,
                                pageSize: catalogState.pageSize,
                                onNextPage: () => ref.read(productCatalogProvider.notifier).nextPage(),
                                onPreviousPage: () => ref.read(productCatalogProvider.notifier).previousPage(),
                                onPageSizeChanged: (size) => ref.read(productCatalogProvider.notifier).setPageSize(size),
                              ),
                              columns: [
                                AppTableColumn<Product>(
                                  label: 'Código / Barras',
                                  width: 140,
                                  builder: (p) => Text(
                                    p.codigoBarras?.isNotEmpty == true ? p.codigoBarras! : 'S/C',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                                AppTableColumn<Product>(
                                  label: 'Nombre Comercial',
                                  width: 200,
                                  builder: (p) => Text(
                                    p.nombreComercial,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: colors.textPrimary,
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
                                    style: TextStyle(fontSize: 12, color: colors.textMuted),
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
                                      style: TextStyle(fontSize: 12, color: colors.textPrimary),
                                    );
                                  },
                                ),
                                AppTableColumn<Product>(
                                  label: 'Stock Disp.',
                                  width: 90,
                                  numeric: true,
                                  builder: (p) {
                                    double totalStock = 0;
                                    for (var pres in p.presentaciones) {
                                      totalStock += stockMap[pres.id!] ?? 0;
                                    }
                                    return Text(
                                      totalStock.toInt().toString(),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: totalStock > 0 ? colors.success : colors.textMuted,
                                      ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: colors.primary,
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
                                      text: tieneIva ? '${(ref.watch(settingsProvider).ivaVigente * 100).toInt()}%' : '0%',
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
                                        Text('Venta Libre', style: TextStyle(fontSize: 11, color: colors.textMuted)),
                                    ],
                                  ),
                                ),
                                AppTableColumn<Product>(
                                  label: 'Acciones',
                                  width: 140,
                                  numeric: true,
                                  builder: (p) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
                                        tooltip: 'Editar producto',
                                        onPressed: () => _onEditProduct(p),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          p.isActive ? Icons.toggle_on : Icons.toggle_off,
                                          size: 22,
                                          color: p.isActive ? colors.success : colors.textMuted,
                                        ),
                                        tooltip: p.isActive ? 'Inactivar' : 'Activar',
                                        onPressed: () => _onToggleStatus(p, stockMap),
                                      ),
                                      if (p.isActive)
                                        IconButton(
                                          icon: Icon(Icons.call_merge, size: 18, color: colors.danger),
                                          tooltip: 'Absorber Duplicados',
                                          onPressed: () => _onMergeProduct(p),
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

  Widget _buildEmptyState(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: colors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No se encontraron medicamentos en el catálogo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Comience registrando un nuevo medicamento con [F2] o modifique los filtros de búsqueda.',
            style: TextStyle(fontSize: 13, color: colors.textMuted),
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
