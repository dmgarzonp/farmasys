import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/catalogo_productos/presentation/views/catalog_screen.dart';
import '../../features/compras_recepcion/presentation/views/purchase_reception_screen.dart';
import '../../features/inventario/presentation/views/inventory_screen.dart';
import '../../features/pos_ventas/presentation/views/pos_screen.dart';
import '../../features/dashboard/presentation/views/dashboard_screen.dart';
import '../../features/configuraciones/presentation/views/settings_screen.dart';

import '../../shared/components/xela_shell_layout.dart';

/// Configuración de navegación declarativa de FarmSys con diseño de shell Xela
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return XelaShellLayout(
            currentLocation: state.uri.path,
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pos',
                name: 'pos',
                builder: (context, state) => const PosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                name: 'catalog',
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                name: 'inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/purchases',
                name: 'purchases',
                builder: (context, state) => const PurchaseReceptionScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
