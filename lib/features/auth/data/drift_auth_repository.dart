import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/usuarios_table.dart';
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
    final passwordHash = sha256.convert(utf8.encode(password)).toString();

    final userRow = await (_db.select(_db.usuariosTable)
          ..where((t) => t.username.equals(username))
          ..where((t) => t.passwordHash.equals(passwordHash))
          ..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();

    if (userRow == null) {
      throw Exception('Credenciales incorrectas o usuario inactivo');
    }

    // Guardar sesión
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, userRow.id);

    return _mapToEntity(userRow);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_sessionKey);

    if (userId == null) return null;

    final userRow = await (_db.select(_db.usuariosTable)
          ..where((t) => t.id.equals(userId))
          ..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();

    if (userRow == null) {
      // Si el usuario ya no existe o fue desactivado, limpiamos la sesión
      await logout();
      return null;
    }

    return _mapToEntity(userRow);
  }

  User _mapToEntity(UsuariosTableData data) {
    return User(
      id: data.id,
      username: data.username,
      role: data.role,
      isActive: data.isActive,
    );
  }
}
