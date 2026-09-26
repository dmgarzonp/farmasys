import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../features/caja/presentation/controllers/cash_session_notifier.dart';
import '../../features/caja/presentation/views/close_cash_dialog.dart';
import '../../features/caja/presentation/views/open_cash_dialog.dart';
import '../../features/compras_recepcion/presentation/controllers/purchase_reception_notifier.dart';
import '../../features/configuraciones/presentation/controllers/settings_notifier.dart';
import '../../shared/components/app_dialogs.dart';
import 'components.dart';

/// Layout base de escritorio estilo Xela UI Kit.
/// Integra la barra lateral fija colapsable, la barra superior contextual
/// y los atajos de teclado globales.
class XelaShellLayout extends ConsumerStatefulWidget {
  final String currentLocation;
  final StatefulNavigationShell navigationShell;

  const XelaShellLayout({
    super.key,
    required this.currentLocation,
    required this.navigationShell,
  });

  @override
  ConsumerState<XelaShellLayout> createState() => _XelaShellLayoutState();
}

class _XelaShellLayoutState extends ConsumerState<XelaShellLayout> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _overrideWindowClose();
  }

  void _overrideWindowClose() async {
    await windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final purchaseState = ref.read(purchaseReceptionProvider);
    final hasDraft = purchaseState.items.isNotEmpty || purchaseState.selectedSupplier != null;

    if (hasDraft) {
      final shouldExit = await AppConfirmDialog.show(
        context,
        title: 'Borrador Guardado',
        message: 'Tienes una recepción de compra en progreso. Se ha guardado un borrador automáticamente.\n\n¿Estás seguro de que deseas salir?',
        confirmText: 'Salir de FarmSys',
        cancelText: 'Continuar Trabajando',
        isDestructive: true,
      );
      if (shouldExit) {
        await windowManager.destroy();
      }
    } else {
      await windowManager.destroy();
    }
  }

  Future<void> _handleOpenCash() async {
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

  Future<void> _handleCloseCash() async {
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

  String _getPageTitle() {
    switch (widget.currentLocation) {
      case '/':
        return 'Dashboard y Alertas';
      case '/pos':
        return 'Punto de Venta & Facturación';
      case '/catalog':
        return 'Catálogo Maestro de Medicamentos';
      case '/inventory':
        return 'Control de Lotes & Trazabilidad FEFO';
      case '/purchases':
        return 'Recepción de Mercadería & Facturas Proveedor';
      default:
        return 'Gestión Farmacéutica';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f1): () => context.go('/pos'),
        const SingleActivator(LogicalKeyboardKey.f2): () => context.go('/'),
        const SingleActivator(LogicalKeyboardKey.f4): () => context.go('/catalog'),
        const SingleActivator(LogicalKeyboardKey.f5): () => context.go('/inventory'),
        const SingleActivator(LogicalKeyboardKey.f7): _handleOpenCash,
        const SingleActivator(LogicalKeyboardKey.f8): _handleCloseCash,
        const SingleActivator(LogicalKeyboardKey.f9): () => context.go('/purchases'),
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de Título Personalizada (Frameless)
            const SizedBox(
              height: 36,
              child: WindowCaption(
                brightness: Brightness.dark,
                backgroundColor: AppColors.primary,
                title: Text(
                  'FarmSys - Tu Farmacia',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // Barra de Navegación Lateral Xela
                  XelaSidebar(
                    currentLocation: widget.currentLocation,
                    onOpenCash: _handleOpenCash,
                    onCloseCash: _handleCloseCash,
                  ),

                  // Área Principal de Trabajo con Header Superior Contextual
                  Expanded(
                    child: Column(
                      children: [
                        _buildHeaderBar(),
                        const Divider(height: 1, color: AppColors.border),
                        Expanded(
                          child: widget.navigationShell,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título y Breadcrumb
          Row(
            children: [
              const Text(
                'FarmSys',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('/', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
              Text(
                _getPageTitle(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Indicadores de Estado de Sistema
          Row(
            children: [
              XelaBadge(
                text: 'SRI ${(ref.watch(settingsProvider).ivaVigente * 100).toInt()}% Activo',
                variant: XelaBadgeVariant.success,
                icon: Icons.verified_user_rounded,
              ),
              const SizedBox(width: 10),
              const XelaBadge(
                text: 'ARCSA FEFO',
                variant: XelaBadgeVariant.purple,
                icon: Icons.fact_check_rounded,
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      'Cajero: Administrador',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
