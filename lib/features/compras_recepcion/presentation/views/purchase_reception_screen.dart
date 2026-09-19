import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_dialogs.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/xela_badge.dart';
import '../../../../shared/components/xela_card.dart';
import '../../../catalogo_productos/data/repositories/drift_product_repository.dart';
import '../../../catalogo_productos/domain/entities/product.dart';
import '../../../catalogo_productos/presentation/views/product_form_dialog.dart';
import '../../../proveedores/presentation/views/supplier_select_dialog.dart';
import '../../domain/entities/purchase_invoice.dart';
import '../controllers/purchase_reception_notifier.dart';
import 'add_reception_item_dialog.dart';
import 'technical_reception_dialog.dart';

/// Pantalla ergonómica desktop para recepción masiva de mercadería y facturas de compra (SOLID: SRP)
class PurchaseReceptionScreen extends ConsumerStatefulWidget {
  const PurchaseReceptionScreen({super.key});

  @override
  ConsumerState<PurchaseReceptionScreen> createState() => _PurchaseReceptionScreenState();
}

class _PurchaseReceptionScreenState extends ConsumerState<PurchaseReceptionScreen> {
  final TextEditingController _invoiceNumCtrl = TextEditingController();
  final TextEditingController _authSriCtrl = TextEditingController();
  final TextEditingController _searchProductCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Product> _matchingProducts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _invoiceNumCtrl.dispose();
    _authSriCtrl.dispose();
    _searchProductCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSelectSupplier() async {
    final supplier = await SupplierSelectDialog.show(context);
    if (supplier != null && mounted) {
      ref.read(purchaseReceptionProvider.notifier).selectSupplier(supplier);
    }
  }

  Future<void> _onSearchProduct(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() => _matchingProducts = []);
      return;
    }

    final productRepo = ref.read(productRepositoryProvider);
    final results = await productRepo.searchProducts(clean);
    if (mounted) {
      setState(() {
        _matchingProducts = results.where((p) => p.isActive && p.presentaciones.isNotEmpty).toList();
      });
    }
  }

  void _onSelectProduct(Product product, ProductPresentation presentation) async {
    setState(() {
      _matchingProducts = [];
      _searchProductCtrl.clear();
    });

    final item = await AddReceptionItemDialog.show(
      context,
      product: product,
      presentation: presentation,
    );

    if (item != null && mounted) {
      ref.read(purchaseReceptionProvider.notifier).addItem(item);
      _searchFocusNode.requestFocus();
    }
  }

  void _onNewProduct() async {
    final newProduct = await ProductFormDialog.show(context);
    if (newProduct != null && mounted) {
      final productRepo = ref.read(productRepositoryProvider);
      final id = await productRepo.saveProduct(newProduct);
      final savedProduct = await productRepo.getProductById(id);

      if (savedProduct != null && savedProduct.presentaciones.isNotEmpty && mounted) {
        _onSelectProduct(savedProduct, savedProduct.presentaciones.first);
      }
    }
  }

  void _onConfirmReception() async {
    final notifier = ref.read(purchaseReceptionProvider.notifier);
    final invoice = await notifier.confirmReception();

    if (invoice != null && mounted) {
      await AppDialogs.showSuccess(
        context,
        title: 'Recepción Asentada con Éxito',
        message: 'Se ingresaron ${invoice.itemCount} renglones (${invoice.totalUnidades.toStringAsFixed(0)} unidades) al inventario.',
        confirmText: 'Ver Acta Técnica ARCSA',
        onConfirm: () {
          TechnicalReceptionDialog.show(context, invoice);
        },
      );
      _invoiceNumCtrl.clear();
      _authSriCtrl.clear();
    } else {
      final err = ref.read(purchaseReceptionProvider).errorMessage;
      if (err != null && mounted) {
        await AppDialogs.showError(context, title: 'No se pudo guardar la recepción', message: err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseReceptionProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f1): _onSelectSupplier,
        const SingleActivator(LogicalKeyboardKey.f2): () => _searchFocusNode.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.f3): _onNewProduct,
        const SingleActivator(LogicalKeyboardKey.f10): _onConfirmReception,
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            // Barra de Acciones de Recepción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Recepción de Mercadería & Facturas de Compra',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  XelaBadge(
                    text: '${state.items.length} renglones',
                    variant: state.items.isNotEmpty ? XelaBadgeVariant.success : XelaBadgeVariant.neutral,
                  ),
                  const Spacer(),
                  AppPrimaryButton(
                    text: 'Confirmar Ingreso a Bodega',
                    shortcutLabel: 'F10',
                    icon: Icons.check_circle_outline,
                    onPressed: state.isValid ? _onConfirmReception : null,
                  ),
                ],
              ),
            ),

            // Cabecera Administrativa de la Factura (Proveedor, Factura, SRI)
            _buildInvoiceHeader(context, state),

            // Buscador rápido y atajo producto nuevo
            _buildProductSearchBar(context),

            // Grid central de renglones ingresados
            Expanded(
              child: _buildItemsDataGrid(context, state),
            ),

            // Barra inferior de totales y cuadre de factura
            _buildBottomSummaryBar(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader(BuildContext context, PurchaseReceptionState state) {
    final supplier = state.selectedSupplier;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: XelaCard(
        padding: const EdgeInsets.all(12),
        child: Row(
        children: [
          // Selector de Proveedor
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: _onSelectSupplier,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: supplier != null ? AppColors.primarySurface : AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: supplier != null ? AppColors.primary.withValues(alpha: 0.4) : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 20,
                      color: supplier != null ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier != null ? supplier.nombreEmpresa : 'Seleccionar Proveedor / Distribuidora [F1] *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: supplier != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            supplier != null ? 'RUC: ${supplier.ruc}' : 'Presione para buscar o registrar distribuidora',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Número de Factura del Proveedor
          Expanded(
            flex: 2,
            child: AppTextField(
              label: 'No. Factura Proveedor *',
              hintText: 'Ej: 001-001-000123456',
              controller: _invoiceNumCtrl,
              onChanged: (val) => ref.read(purchaseReceptionProvider.notifier).setInvoiceNumber(val),
            ),
          ),
          const SizedBox(width: 12),

          // Autorización SRI
          Expanded(
            flex: 3,
            child: AppTextField(
              label: 'Autorización SRI (Opcional)',
              hintText: 'Clave de acceso de 49 dígitos',
              controller: _authSriCtrl,
              onChanged: (val) => ref.read(purchaseReceptionProvider.notifier).setAuthorizationNumber(val),
            ),
          ),
          const SizedBox(width: 12),

          // Fecha Recepción
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fecha Recepción', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(
                  AppFormatters.date(state.receptionDate),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildProductSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _searchProductCtrl,
                  focusNode: _searchFocusNode,
                  hintText: 'Escanear código de barras o escribir nombre del medicamento a recibir [F2]...',
                  prefixIcon: Icons.search,
                  shortcutBadge: 'F2',
                  onChanged: _onSearchProduct,
                ),
              ),
              const SizedBox(width: 12),
              AppPrimaryButton(
                text: 'Nuevo Medicamento',
                shortcutLabel: 'F3',
                icon: Icons.add,
                onPressed: _onNewProduct,
              ),
            ],
          ),
          if (_matchingProducts.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                ],
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _matchingProducts.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final prod = _matchingProducts[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prod.presentaciones.map((pres) {
                      return InkWell(
                        onTap: () => _onSelectProduct(prod, pres),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.medication_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${prod.nombreComercial} - ${pres.nombreDescriptivo}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                '${pres.unidadesPorCaja} un/caja • Costo: ${AppFormatters.currency(pres.precioCompraCaja)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsDataGrid(BuildContext context, PurchaseReceptionState state) {
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text(
              'No hay renglones ingresados en esta factura de compra',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Use el buscador o lector de códigos [F2] para agregar los medicamentos recibidos',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: XelaCard(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 44,
            headingRowColor: WidgetStateProperty.all(AppColors.backgroundDark),
            columns: const [
              DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              DataColumn(label: Text('Medicamento y Presentación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              DataColumn(label: Text('Lote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              DataColumn(label: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              DataColumn(label: Text('Cajas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), numeric: true),
              DataColumn(label: Text('Unidades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), numeric: true),
              DataColumn(label: Text('Costo Caja', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), numeric: true),
              DataColumn(label: Text('IVA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              DataColumn(label: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), numeric: true),
              DataColumn(label: Text('ARCSA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              DataColumn(label: Text('Acción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
            ],
            rows: state.items.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;

              return DataRow(
                cells: [
                  DataCell(Text('$idx', style: const TextStyle(fontSize: 11))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.productoNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(item.presentacionNombre, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  DataCell(Text(item.lote, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataCell(Text(AppFormatters.date(item.fechaVencimiento), style: const TextStyle(fontSize: 11))),
                  DataCell(Text(item.cantidadCajas.toStringAsFixed(0), style: const TextStyle(fontSize: 11))),
                  DataCell(Text(item.cantidadUnidades.toStringAsFixed(0), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  DataCell(Text(AppFormatters.currency(item.costoCaja), style: const TextStyle(fontSize: 11))),
                  DataCell(
                    XelaBadge(
                      text: item.tieneIva ? '12%' : '0%',
                      variant: item.tieneIva ? XelaBadgeVariant.primary : XelaBadgeVariant.neutral,
                    ),
                  ),
                  DataCell(Text(AppFormatters.currency(item.subtotal), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataCell(
                    XelaBadge(
                      text: item.esConformeArcsa ? 'Conforme' : 'Observado',
                      variant: item.esConformeArcsa ? XelaBadgeVariant.success : XelaBadgeVariant.warning,
                      icon: item.esConformeArcsa ? Icons.verified_rounded : Icons.warning_amber_rounded,
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                      tooltip: 'Eliminar renglón',
                      onPressed: () => ref.read(purchaseReceptionProvider.notifier).removeItem(entry.key),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSummaryBar(BuildContext context, PurchaseReceptionState state) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Métricas de Renglones
          Row(
            children: [
              _buildMetricChip('Renglones', '${state.items.length}'),
              const SizedBox(width: 12),
              _buildMetricChip('Total Unidades', state.totalUnidades.toStringAsFixed(0)),
              const SizedBox(width: 16),
              if (state.items.isNotEmpty)
                AppSecondaryButton(
                  text: 'Ver Acta Técnica ARCSA',
                  icon: Icons.verified_outlined,
                  onPressed: () {
                    if (state.selectedSupplier == null) {
                      AppDialogs.showInfo(context, title: 'Atención', message: 'Seleccione un proveedor primero para ver el acta.');
                      return;
                    }
                    final tempInvoice = PurchaseInvoice(
                      proveedorId: state.selectedSupplier!.id ?? 0,
                      proveedorNombre: state.selectedSupplier!.nombreEmpresa,
                      proveedorRuc: state.selectedSupplier!.ruc,
                      numeroFactura: state.invoiceNumber.isNotEmpty ? state.invoiceNumber : 'BORRADOR',
                      fechaEmision: state.invoiceDate,
                      fechaRecepcion: state.receptionDate,
                      subtotalDoce: state.subtotalDoce,
                      subtotalCero: state.subtotalCero,
                      iva: state.iva,
                      total: state.total,
                      items: state.items,
                    );
                    TechnicalReceptionDialog.show(context, tempInvoice);
                  },
                ),
            ],
          ),

          // Cuadre de Factura: Subtotales e IVA
          Row(
            children: [
              _buildTotalItem('Subtotal 0%:', AppFormatters.currency(state.subtotalCero)),
              const SizedBox(width: 16),
              _buildTotalItem('Subtotal 12%:', AppFormatters.currency(state.subtotalDoce)),
              const SizedBox(width: 16),
              _buildTotalItem('IVA 12%:', AppFormatters.currency(state.iva)),
              const SizedBox(width: 24),

              // Total General
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL FACTURA PROVEEDOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    Text(
                      AppFormatters.currency(state.total),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Botón Guardar Recepción
              AppPrimaryButton(
                text: 'Asentar Recepción',
                shortcutLabel: 'F10',
                icon: Icons.check_circle_outline,
                onPressed: state.isValid && !state.isLoading ? _onConfirmReception : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
