import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/theme_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_dialogs.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/components/xela_badge.dart';
import '../../../../shared/components/xela_card.dart';
import '../../../caja/presentation/controllers/cash_session_notifier.dart';
import '../../../caja/presentation/views/close_cash_dialog.dart';
import '../../../caja/presentation/views/open_cash_dialog.dart';
import '../../../catalogo_productos/domain/entities/product.dart';
import '../controllers/pos_search_notifier.dart';
import '../../../clientes/data/repositories/drift_customer_repository.dart';
import '../../../clientes/domain/entities/customer.dart';
import '../../../clientes/presentation/views/customer_select_dialog.dart';
import '../../data/repositories/drift_sale_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../controllers/pos_cart_notifier.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';
import '../../../inventario/presentation/controllers/inventory_notifier.dart';
import 'checkout_dialog.dart';
import 'ticket_preview_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/licensing/application/license_service.dart';
import '../../../../core/licensing/domain/license_info.dart';

/// Pantalla principal del Punto de Venta (POS Desktop) integrada con Caja, Clientes y Despacho FEFO
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(milliseconds: 250);

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
    _debouncer.dispose();
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
        AppSnackBars.showSuccess(
          context,
          message: 'Turno de caja abierto exitosamente con fondo de ${AppFormatters.currency(amount)}.',
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
        AppSnackBars.showInfo(
          context,
          message: 'Turno de caja cerrado y arqueo registrado.',
        );
      }
    }
  }

  void _addToCart(Product product, ProductPresentation presentation, {bool isFraccion = true}) {
    final cartState = ref.read(posCartProvider);
    final availableStockMap = ref.read(availableStockMapProvider).value ?? {};
    final currentStock = availableStockMap[presentation.id!] ?? 0.0;
    
    double currentQtyInCart = 0.0;
    for (final item in cartState.items) {
      if (item.presentacionId == presentation.id!) {
        // Obtenemos las unidades por caja de la presentación que está en el cart, pero asumimos que es constante
        currentQtyInCart += item.isFraccion ? item.quantity : (item.quantity * presentation.unidadesPorCaja);
      }
    }
    
    final unitsToAdd = isFraccion ? 1.0 : presentation.unidadesPorCaja.toDouble();
    if (currentQtyInCart + unitsToAdd > currentStock) {
      AppSnackBars.showError(
        context,
        message: 'Stock insuficiente (Disponibles: ${currentStock.toInt()})',
      );
      return;
    }

    ref.read(posCartProvider.notifier).addItem(
          CartItem(
            presentacionId: presentation.id!,
            productoNombre: product.nombreComercial,
            presentacionNombre: isFraccion ? '${presentation.nombreDescriptivo} (1 Uni)' : presentation.nombreDescriptivo,
            unitPrice: isFraccion ? presentation.precioVentaFraccion : presentation.precioVentaCaja,
            quantity: 1.0,
            hasIva: presentation.tieneIva,
            isFraccion: isFraccion,
            unitsPerBox: presentation.unidadesPorCaja,
          ),
        );

    _searchController.clear();
    setState(() => _searchQuery = '');
    _searchFocusNode.requestFocus();
  }

  void _onSearchSubmitted(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    final searchState = ref.read(posSearchProvider);
    final catalog = searchState.results;

    // 1. Búsqueda exacta por código de barras de presentación o producto
    for (final prod in catalog) {
      for (final pres in prod.presentaciones) {
        if (pres.codigoBarras == clean || prod.codigoBarras == clean) {
          _addToCart(prod, pres, isFraccion: true); // Por defecto añadir fracción al escanear
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
      _addToCart(filtered.first, filtered.first.presentaciones.first, isFraccion: true);
    }
  }

  void _increaseCartQuantity(CartItem item) {
    final cartState = ref.read(posCartProvider);
    final availableStockMap = ref.read(availableStockMapProvider).value ?? {};
    final currentStock = availableStockMap[item.presentacionId] ?? 0.0;
    double currentQtyInCart = 0.0;
    int unitsPerBox = item.unitsPerBox;

    for (final i in cartState.items) {
      if (i.presentacionId == item.presentacionId) {
        currentQtyInCart += i.isFraccion ? i.quantity : (i.quantity * unitsPerBox);
      }
    }
    
    final unitsToAdd = item.isFraccion ? 1.0 : unitsPerBox.toDouble();
    if (currentQtyInCart + unitsToAdd > currentStock) {
      AppSnackBars.showError(
        context,
        message: 'Stock insuficiente (Disponibles: ${currentStock.toInt()})',
      );
      return;
    }

    ref.read(posCartProvider.notifier).updateQuantity(
      item.presentacionId,
      item.isFraccion,
      item.quantity + 1,
    );
  }

  void _onCheckout() async {
    final cartState = ref.read(posCartProvider);
    if (cartState.isEmpty) {
      AppSnackBars.showWarning(context, message: 'El carrito de compras está vacío.');
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

    // Verificar estado de Licencia Comercial (Modo Solo Consulta si expiró)
    final license = ref.read(licenseServiceProvider).asData?.value;
    if (license != null && !license.canSell) {
      if (mounted) {
        final isTampered = license.status == LicenseStatus.tamperedClock;
        await AppDialogs.showWarning(
          context,
          title: isTampered ? 'Reloj Desincronizado' : 'Licencia Requerida',
          message: isTampered
              ? 'Se detectó una alteración en la fecha u hora del sistema operativo. Por favor sincroniza el reloj oficial de tu equipo para continuar facturando.'
              : 'La suscripción de FarmSys ha expirado o este equipo no tiene una licencia activa. El sistema opera en Modo Solo Consulta. Por favor activa tu licencia en Configuración para registrar ventas.',
        );
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

        // Mostrar vista previa del comprobante interno
        final cashierName = ref.read(authControllerProvider).user?.username ?? 'Cajero';
        
        // Limpiar carrito antes de mostrar el modal para que el POS quede listo atrás
        ref.read(posCartProvider.notifier).clear();

        if (mounted) {
          // Se abrirá el modal interactivo de PdfPreview
          await TicketPreviewDialog.show(
            context,
            sale: completedSale,
            cashierName: cashierName,
          );
        }

        if (mounted) {
          AppSnackBars.showSuccess(
            context,
            message: 'Venta #${completedSale.id} procesada exitosamente. Lotes FEFO descontados.',
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        if (mounted) {
          AppSnackBars.showError(
            context,
            message: 'Error al procesar la venta: $e',
            duration: const Duration(seconds: 5),
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
          backgroundColor: context.colors.background,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel Izquierdo: Catálogo Rápido y Búsqueda
              Expanded(
                flex: 6,
                child: _buildProductCatalogPanel(context),
              ),
              VerticalDivider(width: 1, color: context.colors.border),

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
    final colors = context.colors;
    final searchState = ref.watch(posSearchProvider);
    final availableStockMap = ref.watch(availableStockMapProvider).value ?? {};
    final filtered = searchState.results;

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
            onChanged: (val) => _debouncer.run(() {
              setState(() => _searchQuery = val);
              ref.read(posSearchProvider.notifier).search(val);
            }),
            onSubmitted: _onSearchSubmitted,
          ),
          const SizedBox(height: 12),

          // Título de la lista rápida
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isEmpty ? 'MEDICAMENTOS DISPONIBLES (${filtered.length})' : 'RESULTADOS DE BÚSQUEDA (${filtered.length})',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textSecondary, letterSpacing: 0.5),
              ),
              Text(
                'Presione sobre una presentación para añadir al carrito',
                style: TextStyle(fontSize: 11, color: colors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de Productos y Presentaciones
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: colors.textMuted),
                        const SizedBox(height: 8),
                        Text('No se encontraron medicamentos coincidentes.', style: TextStyle(color: colors.textSecondary)),
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
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: colors.textPrimary),
                                ),
                                if (prod.concentracion != null && prod.concentracion!.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text('(${prod.concentracion})', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
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
                                  style: TextStyle(fontSize: 11, color: colors.textMuted),
                                ),
                              ),
                            const SizedBox(height: 8),

                            // Presentaciones seleccionables (Caja y Unidad)
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: prod.presentaciones.expand((pres) {
                                final stock = availableStockMap[pres.id!] ?? 0.0;
                                final agotado = stock <= 0;
                                
                                return [
                                  // Botón Unidad/Fracción
                                  ActionChip(
                                    avatar: Icon(agotado ? Icons.block : Icons.medication, size: 14, color: agotado ? colors.textMuted : colors.primary),
                                    label: Text(
                                      agotado ? 'Agotado' : '1 Uni (Stock: ${stock.toInt()}) • ${AppFormatters.currency(pres.precioVentaFraccion)}',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: agotado ? colors.textMuted : colors.textPrimary),
                                    ),
                                    backgroundColor: agotado ? colors.divider : colors.primarySurface,
                                    side: BorderSide(color: agotado ? colors.border : colors.primary.withValues(alpha: 0.3)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    onPressed: agotado ? null : () => _addToCart(prod, pres, isFraccion: true),
                                  ),
                                  // Botón Caja Completa
                                  if (pres.unidadesPorCaja > 1)
                                    ActionChip(
                                      avatar: Icon(stock < pres.unidadesPorCaja ? Icons.block : Icons.inventory_2_outlined, size: 14, color: colors.textSecondary),
                                      label: Text(
                                        stock < pres.unidadesPorCaja ? 'Caja Agotada' : 'Caja (${pres.unidadesPorCaja}u) • ${AppFormatters.currency(pres.precioVentaCaja)}',
                                        style: TextStyle(fontSize: 11, color: stock < pres.unidadesPorCaja ? colors.textMuted : colors.textSecondary),
                                      ),
                                      backgroundColor: colors.surface,
                                      side: BorderSide(color: colors.border),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      onPressed: stock < pres.unidadesPorCaja ? null : () => _addToCart(prod, pres, isFraccion: false),
                                    ),
                                ];
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
    final colors = context.colors;
    return Container(
      color: colors.cardBackground,
      child: Column(
        children: [
          // Selector de Cliente en Cabecera del Carrito
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colors.background,
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
                              ? colors.pillNeutralBg
                              : colors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _selectedCustomer.isConsumidorFinal ? Icons.public : Icons.person,
                          size: 18,
                          color: _selectedCustomer.isConsumidorFinal
                              ? colors.pillNeutralText
                              : colors.primary,
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
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
                              style: TextStyle(fontSize: 10, color: colors.textSecondary),
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
          Divider(height: 1, color: colors.border),

          // Título del Carrito
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colors.cardBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CARRITO DE VENTA',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textSecondary, letterSpacing: 0.5),
                ),
                Text(
                  '${cartState.items.length} ítems',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.primary),
                ),
              ],
            ),
          ),

          // Lista de Ítems en Carrito
          Expanded(
            child: cartState.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'El carrito está vacío',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Busque medicamentos en el panel izquierdo [F2]',
                          style: TextStyle(fontSize: 11, color: colors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: colors.divider),
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
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                  Text(
                                    '${item.presentacionNombre} • ${AppFormatters.currency(item.unitPrice)} c/u',
                                    style: TextStyle(fontSize: 10, color: colors.textSecondary),
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
                                  color: colors.textSecondary,
                                  onPressed: () => ref.read(posCartProvider.notifier).updateQuantity(
                                        item.presentacionId,
                                        item.isFraccion,
                                        item.quantity - 1,
                                      ),
                                ),
                                Text(
                                  '${item.quantity.toInt()}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 18),
                                  color: colors.primary,
                                  onPressed: () => _increaseCartQuantity(item),
                                ),
                              ],
                            ),

                            // Subtotal del ítem
                            SizedBox(
                              width: 65,
                              child: Text(
                                AppFormatters.currency(item.netSubtotal),
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textPrimary),
                              ),
                            ),

                            // Eliminar
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: colors.danger),
                              onPressed: () => ref.read(posCartProvider.notifier).removeItem(item.presentacionId, item.isFraccion),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          Divider(height: 1, color: colors.border),

          // Liquidación Tributaria y Total General
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              border: Border(
                top: BorderSide(color: colors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                _buildTotalRow('Subtotal 0% (Medicamentos)', cartState.totals.subtotal0, colors),
                const SizedBox(height: 4),
                _buildTotalRow('Subtotal ${(ref.watch(settingsProvider).ivaVigente * 100).toInt()}%', cartState.totals.subtotalIva, colors),
                const SizedBox(height: 4),
                _buildTotalRow('IVA ${(ref.watch(settingsProvider).ivaVigente * 100).toInt()}%', cartState.totals.ivaAmount, colors),
                const SizedBox(height: 10),
                Divider(height: 1, color: colors.border),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL A PAGAR',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    Text(
                      AppFormatters.currency(cartState.totals.grandTotal),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
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

  Widget _buildTotalRow(String label, double amount, AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
        Text(AppFormatters.currency(amount), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary)),
      ],
    );
  }
}
