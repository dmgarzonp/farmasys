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
import '../../../caja/presentation/controllers/cash_session_notifier.dart';
import '../../../caja/presentation/views/close_cash_dialog.dart';
import '../../../caja/presentation/views/open_cash_dialog.dart';
import '../../../catalogo_productos/domain/entities/product.dart';
import '../../../catalogo_productos/presentation/controllers/product_catalog_notifier.dart';
import '../../../clientes/data/repositories/drift_customer_repository.dart';
import '../../../clientes/domain/entities/customer.dart';
import '../../../clientes/presentation/views/customer_select_dialog.dart';
import '../../data/repositories/drift_sale_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../controllers/pos_cart_notifier.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';
import 'checkout_dialog.dart';

/// Pantalla principal del Punto de Venta (POS Desktop) integrada con Caja, Clientes y Despacho FEFO
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Customer _selectedCustomer = Customer.consumidorFinal();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDefaultCustomer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultCustomer() async {
    final customerRepo = ref.read(customerRepositoryProvider);
    final cf = await customerRepo.getConsumidorFinal();
    if (mounted) {
      setState(() => _selectedCustomer = cf);
    }
  }

  void _onSelectCustomer() async {
    final selected = await CustomerSelectDialog.show(context);
    if (selected != null && mounted) {
      setState(() => _selectedCustomer = selected);
      ref.read(posCartProvider.notifier).selectClient(selected.id, selected.nombreCompleto);
    }
  }

  void _onOpenCash() async {
    final amount = await OpenCashDialog.show(context);
    if (amount != null && mounted) {
      final success = await ref.read(cashSessionProvider.notifier).openSession(montoInicial: amount);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Turno de caja abierto exitosamente con fondo de ${AppFormatters.currency(amount)}.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _onCloseCash() async {
    final session = ref.read(cashSessionProvider).activeSession;
    if (session == null) return;

    final result = await CloseCashDialog.show(context, session);
    if (result != null && mounted) {
      final success = await ref.read(cashSessionProvider.notifier).closeSession(
            montoFinalEfectivo: result['efectivo'] as double,
            montoFinalTarjeta: result['tarjeta'] as double?,
            montoFinalTransferencia: result['transferencia'] as double?,
            observaciones: result['observaciones'] as String?,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turno de caja cerrado y arqueo registrado.'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    }
  }

  void _addToCart(Product product, ProductPresentation presentation) {
    ref.read(posCartProvider.notifier).addItem(
          CartItem(
            presentacionId: presentation.id!,
            productoNombre: product.nombreComercial,
            presentacionNombre: presentation.nombreDescriptivo,
            unitPrice: presentation.precioVentaCaja,
            quantity: 1.0,
            hasIva: presentation.tieneIva,
          ),
        );

    _searchController.clear();
    setState(() => _searchQuery = '');
    _searchFocusNode.requestFocus();
  }

  void _onSearchSubmitted(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    final catalog = ref.read(productCatalogProvider).products;

    // 1. Búsqueda exacta por código de barras de presentación o producto
    for (final prod in catalog) {
      for (final pres in prod.presentaciones) {
        if (pres.codigoBarras == clean || prod.codigoBarras == clean) {
          _addToCart(prod, pres);
          return;
        }
      }
    }

    // 2. Si solo hay 1 producto filtrado con 1 presentación, añadir directamente
    final filtered = catalog
        .where((p) =>
            p.isActive &&
            p.presentaciones.isNotEmpty &&
            (p.nombreComercial.toLowerCase().contains(clean.toLowerCase()) ||
                (p.principioActivo?.toLowerCase().contains(clean.toLowerCase()) ?? false)))
        .toList();

    if (filtered.length == 1 && filtered.first.presentaciones.length == 1) {
      _addToCart(filtered.first, filtered.first.presentaciones.first);
    }
  }

  void _onCheckout() async {
    final cartState = ref.read(posCartProvider);
    if (cartState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito de compras está vacío.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    // Verificar si la caja está abierta
    final cashState = ref.read(cashSessionProvider);
    if (!cashState.hasActiveSession) {
      final shouldOpen = await AppConfirmDialog.show(
        context,
        title: 'Caja Cerrada',
        message: 'No existe un turno de caja abierto. ¿Desea abrir caja ahora para poder facturar?',
        confirmText: 'Abrir Caja [F7]',
      );
      if (shouldOpen && mounted) {
        _onOpenCash();
      }
      return;
    }

    // Abrir Modal de Checkout
    final checkoutResult = await CheckoutDialog.show(
      context,
      totals: cartState.totals,
      customer: _selectedCustomer,
    );

    if (checkoutResult != null && mounted) {
      try {
        final saleHeader = Sale(
          clienteId: _selectedCustomer.id,
          clienteNombre: _selectedCustomer.nombreCompleto,
          clienteDocumento: _selectedCustomer.documento,
          usuarioId: 1,
          sesionCajaId: cashState.activeSession!.id!,
          fechaVenta: DateTime.now(),
          subtotal0: cartState.totals.subtotal0,
          subtotal12: cartState.totals.subtotalIva,
          descuentoTotal: cartState.totals.totalDiscount,
          impuestoTotal: cartState.totals.ivaAmount,
          total: cartState.totals.grandTotal,
          metodoPago: checkoutResult['metodoPago'] as String,
        );

        final saleRepo = ref.read(saleRepositoryProvider);
        final completedSale = await saleRepo.processSale(
          saleHeader: saleHeader,
          cartItems: cartState.items,
        );

        // Limpiar carrito
        ref.read(posCartProvider.notifier).clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Venta #${completedSale.id} procesada exitosamente. Lotes FEFO descontados.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar la venta: $e'),
              backgroundColor: AppColors.danger,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(posCartProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f1): _onCheckout,
        const SingleActivator(LogicalKeyboardKey.f12): _onCheckout,
        const SingleActivator(LogicalKeyboardKey.f2): () => _searchFocusNode.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.f6): _onSelectCustomer,
        const SingleActivator(LogicalKeyboardKey.f7): _onOpenCash,
        const SingleActivator(LogicalKeyboardKey.f8): _onCloseCash,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (!cartState.isEmpty) {
            ref.read(posCartProvider.notifier).clear();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel Izquierdo: Catálogo Rápido y Búsqueda
              Expanded(
                flex: 6,
                child: _buildProductCatalogPanel(context),
              ),
              const VerticalDivider(width: 1, color: AppColors.border),

              // Panel Derecho: Carrito, Cliente, Impuestos y Cobro
              Expanded(
                flex: 4,
                child: _buildCartPanel(context, cartState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCatalogPanel(BuildContext context) {
    final catalogState = ref.watch(productCatalogProvider);
    final allProducts = catalogState.products.where((p) => p.isActive && p.presentaciones.isNotEmpty).toList();

    final filtered = _searchQuery.trim().isEmpty
        ? allProducts
        : allProducts.where((p) {
            final q = _searchQuery.toLowerCase();
            return p.nombreComercial.toLowerCase().contains(q) ||
                (p.principioActivo?.toLowerCase().contains(q) ?? false) ||
                (p.codigoBarras?.contains(q) ?? false) ||
                p.presentaciones.any((pres) => pres.codigoBarras?.contains(q) ?? false);
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buscador rápido con lector de códigos de barra
          AppTextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            hintText: 'Escanear código de barras o escribir nombre del medicamento [F2]...',
            prefixIcon: Icons.search,
            shortcutBadge: 'F2',
            onChanged: (val) => setState(() => _searchQuery = val),
            onSubmitted: _onSearchSubmitted,
          ),
          const SizedBox(height: 12),

          // Título de la lista rápida
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isEmpty ? 'MEDICAMENTOS DISPONIBLES (${filtered.length})' : 'RESULTADOS DE BÚSQUEDA (${filtered.length})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              const Text(
                'Presione sobre una presentación para añadir al carrito',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de Productos y Presentaciones
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 8),
                        Text('No se encontraron medicamentos coincidentes.', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final prod = filtered[index];
                      return XelaCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  prod.nombreComercial,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                ),
                                if (prod.concentracion != null && prod.concentracion!.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text('(${prod.concentracion})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                                const Spacer(),
                                if (prod.requiereReceta)
                                  const XelaBadge(
                                    text: 'Receta Médica',
                                    variant: XelaBadgeVariant.danger,
                                    icon: Icons.assignment_late_outlined,
                                  ),
                              ],
                            ),
                            if (prod.principioActivo != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  prod.principioActivo!,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ),
                            const SizedBox(height: 8),

                            // Presentaciones seleccionables
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: prod.presentaciones.map((pres) {
                                return ActionChip(
                                  avatar: const Icon(Icons.add_shopping_cart, size: 14, color: AppColors.primary),
                                  label: Text(
                                    '${pres.nombreDescriptivo} • ${AppFormatters.currency(pres.precioVentaCaja)} ${pres.tieneIva ? '(IVA ${(ref.watch(settingsProvider).ivaVigente * 100).toInt()}%)' : '(0%)'}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: AppColors.background,
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  onPressed: () => _addToCart(prod, pres),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartPanel(BuildContext context, PosCartState cartState) {
    return Container(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          // Selector de Cliente en Cabecera del Carrito
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _selectedCustomer.isConsumidorFinal
                              ? AppColors.pillNeutralBg
                              : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _selectedCustomer.isConsumidorFinal ? Icons.public : Icons.person,
                          size: 18,
                          color: _selectedCustomer.isConsumidorFinal
                              ? AppColors.pillNeutralText
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _selectedCustomer.nombreCompleto,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                XelaBadge(
                                  text: _selectedCustomer.isConsumidorFinal ? 'Final' : 'RUC/Cédula',
                                  variant: _selectedCustomer.isConsumidorFinal
                                      ? XelaBadgeVariant.neutral
                                      : XelaBadgeVariant.info,
                                ),
                              ],
                            ),
                            Text(
                              'DOC: ${_selectedCustomer.documento}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSecondaryButton(
                  text: 'Cliente',
                  shortcutLabel: 'F6',
                  icon: Icons.person_search,
                  onPressed: _onSelectCustomer,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Título del Carrito
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.cardBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CARRITO DE VENTA',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                Text(
                  '${cartState.items.length} ítems',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Lista de Ítems en Carrito
          Expanded(
            child: cartState.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'El carrito está vacío',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Busque medicamentos en el panel izquierdo [F2]',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final item = cartState.items[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productoNombre,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    '${item.presentacionNombre} • ${AppFormatters.currency(item.unitPrice)} c/u',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),

                            // Controles de Cantidad (+ / -)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                                  color: AppColors.textSecondary,
                                  onPressed: () => ref.read(posCartProvider.notifier).updateQuantity(
                                        item.presentacionId,
                                        item.quantity - 1,
                                      ),
                                ),
                                Text(
                                  '${item.quantity.toInt()}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 18),
                                  color: AppColors.primary,
                                  onPressed: () => ref.read(posCartProvider.notifier).updateQuantity(
                                        item.presentacionId,
                                        item.quantity + 1,
                                      ),
                                ),
                              ],
                            ),

                            // Subtotal del ítem
                            SizedBox(
                              width: 65,
                              child: Text(
                                AppFormatters.currency(item.netSubtotal),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),

                            // Eliminar
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                              onPressed: () => ref.read(posCartProvider.notifier).removeItem(item.presentacionId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const Divider(height: 1),

          // Liquidación Tributaria y Total General
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                _buildTotalRow('Subtotal 0% (Medicamentos)', cartState.totals.subtotal0),
                const SizedBox(height: 4),
                _buildTotalRow('Subtotal ${(ref.watch(settingsProvider).ivaVigente * 100).toInt()}%', cartState.totals.subtotalIva),
                const SizedBox(height: 4),
                _buildTotalRow('IVA ${(ref.watch(settingsProvider).ivaVigente * 100).toInt()}%', cartState.totals.ivaAmount),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL A PAGAR',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      AppFormatters.currency(cartState.totals.grandTotal),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppPrimaryButton(
                  text: 'Cobrar y Facturar',
                  shortcutLabel: 'F1',
                  icon: Icons.payments_outlined,
                  onPressed: cartState.canCheckout ? _onCheckout : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(AppFormatters.currency(amount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
