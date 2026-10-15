import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/usuarios_table.dart';
import '../../../../core/security/password_hasher.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftAuthRepository(db);
});

class DriftAuthRepository implements AuthRepository {
  final AppDatabase _db;
  static const _sessionKey = 'auth_session_user_id';

  DriftAuthRepository(this._db);

  @override
  Future<User> login(String username, String password) async {
    final userRow = await (_db.select(_db.usuariosTable)
          ..where((t) => t.username.equals(username))
          ..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();

    if (userRow == null || !PasswordHasher.verify(password, userRow.passwordHash)) {
      throw Exception('Credenciales incorrectas o usuario inactivo');
    }

    // Auto-migración transparente: si el hash era legado sin sal, se actualiza a sal criptográfica
    if (PasswordHasher.needsRehash(userRow.passwordHash)) {
      final updatedHash = PasswordHasher.hashPassword(password);
      await (_db.update(_db.usuariosTable)..where((t) => t.id.equals(userRow.id)))
          .write(UsuariosTableCompanion(passwordHash: Value(updatedHash)));
    }

    return _mapToEntity(userRow);
  }

  @override
  Future<void> logout() async {
    // Al no haber persistencia, el logout solo impactará el estado en memoria 
    // manejado por el AuthNotifier.
  }

  @override
  Future<User?> getCurrentUser() async {
    // Siempre retornamos null al iniciar para forzar que el trabajador deba 
    // ingresar sus credenciales en la pantalla de Login.
    return null;
  }

  @override
  Future<void> changePassword(int userId, String newPassword) async {
    final passwordHash = PasswordHasher.hashPassword(newPassword);

    final companion = UsuariosTableCompanion(
      passwordHash: Value(passwordHash),
      requiresPasswordChange: const Value(false),
    );

    await (_db.update(_db.usuariosTable)..where((t) => t.id.equals(userId))).write(companion);
  }

  User _mapToEntity(UsuariosTableData data) {
    return User(
      id: data.id,
      username: data.username,
      role: data.role,
      isActive: data.isActive,
      requiresPasswordChange: data.requiresPasswordChange,
      fullName: data.fullName,
      documento: data.documento,
      telefonoFijo: data.telefonoFijo,
      telefonoMovil: data.telefonoMovil,
      correoPersonal: data.correoPersonal,
      hireDate: data.hireDate,
    );
  }
}
