import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/catalogo_productos/presentation/views/catalog_screen.dart';
import '../../features/compras_recepcion/presentation/views/purchase_reception_screen.dart';
import '../../features/inventario/presentation/views/inventory_screen.dart';
import '../../features/pos_ventas/presentation/views/pos_screen.dart';
import '../../features/dashboard/presentation/views/dashboard_screen.dart';
import '../../features/configuraciones/presentation/views/settings_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/change_password_screen.dart';
import '../../features/usuarios/presentation/screens/users_list_screen.dart';
import '../database/tables/usuarios_table.dart';

import '../../shared/components/xela_shell_layout.dart';

/// Configuración de navegación declarativa de FarmSys con diseño de shell Xela
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.uri.path == '/login';
      final isAuth = authState.status == AuthStatus.authenticated;

      if (authState.isLoading) {
        if (!isLoggingIn) return '/login';
        return null;
      }

      if (!isAuth && !isLoggingIn) return '/login';
      
      if (isAuth) {
        final user = authState.user;
        final role = user?.role;
        final path = state.uri.path;
        final isChangingPassword = path == '/change-password';

        // Bloqueo Forzoso: Si el usuario requiere cambio de clave
        if (user?.requiresPasswordChange == true) {
          if (!isChangingPassword) return '/change-password';
          return null; // Permitir que se quede en change-password
        }

        // Si ya no requiere cambio de clave y está intentando acceder a change-password, lo sacamos
        if (isChangingPassword) {
           return role == UserRole.cajero ? '/pos' : '/';
        }

        if (isLoggingIn) {
          // Redirección inicial post-login según rol
          return role == UserRole.cajero ? '/pos' : '/';
        }

        // RBAC Guards
        if (role == UserRole.cajero) {
          // Cajeros solo tienen acceso a POS
          if (path != '/pos') return '/pos';
        } else if (role == UserRole.farmaceutico) {
          // Farmacéuticos no tienen acceso a configuración ni personal
          if (path == '/settings' || path == '/usuarios') return '/';
        } else if (role == UserRole.administrador) {
          // Admin tiene acceso a todo. (Sin restricciones)
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change_password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/usuarios',
                name: 'usuarios',
                builder: (context, state) => const UsersListScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
