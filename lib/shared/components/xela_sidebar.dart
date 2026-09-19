import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../features/caja/presentation/controllers/cash_session_notifier.dart';
import 'xela_badge.dart';
import 'xela_card.dart';

/// Barra lateral de navegación estilo Xela UI Kit para escritorio
class XelaSidebar extends ConsumerStatefulWidget {
  final String currentLocation;
  final VoidCallback onOpenCash;
  final VoidCallback onCloseCash;

  const XelaSidebar({
    super.key,
    required this.currentLocation,
    required this.onOpenCash,
    required this.onCloseCash,
  });

  @override
  ConsumerState<XelaSidebar> createState() => _XelaSidebarState();
}

class _XelaSidebarState extends ConsumerState<XelaSidebar> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final cashState = ref.watch(cashSessionProvider);
    final width = _isExpanded ? 230.0 : 68.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de Marca
          _buildBrandHeader(),
          const Divider(height: 1, color: AppColors.sidebarBorder),

          // Enlaces de Navegación
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildNavItem(
                  label: 'Dashboard',
                  route: '/',
                  icon: Icons.dashboard_rounded,
                  shortcut: 'F2',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  label: 'Punto de Venta',
                  route: '/pos',
                  icon: Icons.point_of_sale_rounded,
                  shortcut: 'F1',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  label: 'Catálogo Maestro',
                  route: '/catalog',
                  icon: Icons.inventory_2_outlined,
                  shortcut: 'F4',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  label: 'Inventario FEFO',
                  route: '/inventory',
                  icon: Icons.warehouse_outlined,
                  shortcut: 'F5',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  label: 'Recepción Compras',
                  route: '/purchases',
                  icon: Icons.receipt_long_outlined,
                  shortcut: 'F9',
                ),
              ],
            ),
          ),

          // Tarjeta de Control de Caja
          _buildCashSection(cashState),

          const Divider(height: 1, color: AppColors.sidebarBorder),

          // Pie de barra con botón colapsar/expandir
          _buildCollapseToggle(),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16 : 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_pharmacy_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Farmacia POS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required String route,
    required IconData icon,
    required String shortcut,
  }) {
    final isActive = widget.currentLocation == route;

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(10),
        hoverColor: AppColors.sidebarHoverBg,
        child: Container(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 12 : 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.sidebarActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.sidebarActiveText : AppColors.sidebarInactiveText,
              ),
              if (_isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.sidebarActiveText : AppColors.sidebarInactiveText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isActive ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    shortcut,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.primaryDark : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!_isExpanded) {
      return Tooltip(
        message: '$label [$shortcut]',
        waitDuration: const Duration(milliseconds: 300),
        child: content,
      );
    }

    return content;
  }

  Widget _buildCashSection(CashSessionState cashState) {
    final isCashOpen = cashState.hasActiveSession;
    final session = cashState.activeSession;

    if (!_isExpanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Tooltip(
          message: isCashOpen ? 'Caja Abierta [F8]' : 'Caja Cerrada [F7]',
          child: InkWell(
            onTap: isCashOpen ? widget.onCloseCash : widget.onOpenCash,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCashOpen ? AppColors.pillSuccessBg : AppColors.pillWarningBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCashOpen ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                size: 20,
                color: isCashOpen ? AppColors.pillSuccessText : AppColors.pillWarningText,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: XelaCard(
        padding: const EdgeInsets.all(10),
        color: isCashOpen ? AppColors.primarySurface : AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                XelaBadge(
                  text: isCashOpen ? 'Caja #${session?.id ?? ''}' : 'Caja Cerrada',
                  variant: isCashOpen ? XelaBadgeVariant.success : XelaBadgeVariant.warning,
                  icon: isCashOpen ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isCashOpen ? 'Turno en Operación' : 'Sin turno activo',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton.icon(
                onPressed: isCashOpen ? widget.onCloseCash : widget.onOpenCash,
                icon: Icon(
                  isCashOpen ? Icons.lock_rounded : Icons.key_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                label: Text(
                  isCashOpen ? 'Cerrar [F8]' : 'Abrir [F7]',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCashOpen ? AppColors.secondary : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapseToggle() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16 : 0),
        alignment: _isExpanded ? Alignment.centerLeft : Alignment.center,
        child: Row(
          mainAxisAlignment: _isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              _isExpanded ? Icons.keyboard_double_arrow_left_rounded : Icons.keyboard_double_arrow_right_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            if (_isExpanded) ...[
              const SizedBox(width: 8),
              const Text(
                'Colapsar Menú',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
