import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Intenta iniciar sesión con el username y password dados.
  /// Retorna el [User] si tiene éxito, o lanza una excepción si falla.
  Future<User> login(String username, String password);

  /// Cierra la sesión actual, limpiando los tokens o estado local.
  Future<void> logout();

  /// Recupera el usuario actualmente logueado (ej. desde SharedPreferences).
  /// Retorna nulo si no hay sesión activa.
  Future<User?> getCurrentUser();
}
