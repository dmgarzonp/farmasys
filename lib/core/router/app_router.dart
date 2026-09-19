import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/catalogo_productos/presentation/views/catalog_screen.dart';
import '../../features/compras_recepcion/presentation/views/purchase_reception_screen.dart';
import '../../features/inventario/presentation/views/inventory_screen.dart';
import '../../features/pos_ventas/presentation/views/pos_screen.dart';
import '../../features/dashboard/presentation/views/dashboard_screen.dart';

import '../../shared/components/xela_shell_layout.dart';

/// Configuración de navegación declarativa de FarmSys con diseño de shell Xela
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return XelaShellLayout(
            currentLocation: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/pos',
            name: 'pos',
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            builder: (context, state) => const CatalogScreen(),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/purchases',
            name: 'purchases',
            builder: (context, state) => const PurchaseReceptionScreen(),
          ),
        ],
      ),
    ],
  );
});
