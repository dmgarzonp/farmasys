import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart' hide UserRole;
import '../../core/theme/app_theme_colors.dart';
import '../extensions/theme_extensions.dart';
import '../../features/caja/presentation/controllers/cash_session_notifier.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../core/database/tables/usuarios_table.dart';
import '../../features/configuraciones/presentation/controllers/settings_notifier.dart';
import 'components.dart';

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
    final userRole = ref.watch(authControllerProvider).user?.role;
    final width = _isExpanded ? 230.0 : 68.0;
    final colors = AppColors.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: colors.sidebarBg,
        border: Border(
          right: BorderSide(color: colors.sidebarBorder, width: 1),
        ),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          minWidth: 230,
          maxWidth: 230,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de Marca
              _buildBrandHeader(colors),
              Divider(height: 1, color: colors.sidebarBorder),

              // Enlaces de Navegación
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    if (userRole == UserRole.administrador || userRole == UserRole.farmaceutico) ...[
                      _buildNavItem(
                        colors: colors,
                        label: 'Dashboard',
                        route: '/',
                        icon: Icons.dashboard_rounded,
                        shortcut: 'F2',
                      ),
                      const SizedBox(height: 6),
                    ],
                    _buildNavItem(
                      colors: colors,
                      label: 'Punto de Venta',
                      route: '/pos',
                      icon: Icons.point_of_sale_rounded,
                      shortcut: 'F1',
                    ),
                    const SizedBox(height: 6),
                    if (userRole == UserRole.administrador || userRole == UserRole.farmaceutico) ...[
                      _buildNavItem(
                        colors: colors,
                        label: 'Catálogo Maestro',
                        route: '/catalog',
                        icon: Icons.inventory_2_outlined,
                        shortcut: 'F4',
                      ),
                      const SizedBox(height: 6),
                      _buildNavItem(
                        colors: colors,
                        label: 'Inventario FEFO',
                        route: '/inventory',
                        icon: Icons.warehouse_outlined,
                        shortcut: 'F5',
                      ),
                      const SizedBox(height: 6),
                      _buildNavItem(
                        colors: colors,
                        label: 'Recepción Compras',
                        route: '/purchases',
                        icon: Icons.receipt_long_outlined,
                        shortcut: 'F9',
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (userRole == UserRole.administrador) ...[
                      _buildNavItem(
                        colors: colors,
                        label: 'Usuarios',
                        route: '/usuarios',
                        icon: Icons.manage_accounts_rounded,
                        shortcut: 'U',
                      ),
                      const SizedBox(height: 6),
                      _buildNavItem(
                        colors: colors,
                        label: 'Configuraciones',
                        route: '/settings',
                        icon: Icons.settings_rounded,
                        shortcut: 'F12',
                      ),
                    ],
                  ],
                ),
              ),

              // Tarjeta de Control de Caja
              _buildCashSection(cashState, colors),

              Divider(height: 1, color: colors.sidebarBorder),

              // Pie de barra con botón colapsar/expandir
              _buildCollapseToggle(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(AppThemeColors colors) {
    final settings = ref.watch(settingsProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: settings.primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: settings.primaryColor.withValues(alpha: 0.25),
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
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.pharmacyName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'FarmSys POS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required AppThemeColors colors,
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
        hoverColor: colors.sidebarHoverBg,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isActive ? colors.sidebarActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? colors.sidebarActiveText : colors.sidebarInactiveText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isExpanded ? 1.0 : 0.0,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? colors.sidebarActiveText : colors.sidebarInactiveText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isExpanded ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? colors.sidebarActiveBg : colors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isActive ? colors.primaryLight.withValues(alpha: 0.3) : colors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    shortcut,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? colors.sidebarActiveText : colors.textMuted,
                    ),
                  ),
                ),
              ),
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

  Widget _buildCashSection(CashSessionState cashState, AppThemeColors colors) {
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
                color: isCashOpen ? colors.pillSuccessBg : colors.pillWarningBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCashOpen ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                size: 20,
                color: isCashOpen ? colors.pillSuccessText : colors.pillWarningText,
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
        color: isCashOpen ? colors.primarySurface : colors.cardBackground,
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
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
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
                  backgroundColor: isCashOpen ? colors.secondary : colors.primary,
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

  Widget _buildCollapseToggle(AppThemeColors colors) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16 : 25), // 25 centers the 18px icon in a 68px box
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              _isExpanded ? Icons.keyboard_double_arrow_left_rounded : Icons.keyboard_double_arrow_right_rounded,
              size: 18,
              color: colors.textMuted,
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Text(
                'Colapsar Menú',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
