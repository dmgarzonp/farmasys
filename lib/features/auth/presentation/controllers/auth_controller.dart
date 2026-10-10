import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/drift_auth_repository.dart';

part 'auth_controller.g.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Puede ser null
    );
  }
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    _checkInitialSession();
    return const AuthState(isLoading: true);
  }

  Future<void> _checkInitialSession() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();
      
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(username, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> changePassword(String newPassword) async {
    final user = state.user;
    if (user == null) return;
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.changePassword(user.id, newPassword);
      
      // Actualizamos el usuario en memoria para reflejar que ya no requiere cambio
      // y refrescar el router
      final updatedUser = User(
        id: user.id,
        username: user.username,
        role: user.role,
        isActive: user.isActive,
        requiresPasswordChange: false,
        fullName: user.fullName,
        documento: user.documento,
        telefonoFijo: user.telefonoFijo,
        telefonoMovil: user.telefonoMovil,
        correoPersonal: user.correoPersonal,
        hireDate: user.hireDate,
      );
      
      state = AuthState(status: AuthStatus.authenticated, user: updatedUser);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      throw e;
    }
  }
}
