import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/usuarios_table.dart';
import '../../auth/domain/entities/user_entity.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftUsersRepository(db);
});

abstract class UsersRepository {
  Future<List<User>> getUsers();
  Future<User> createUser({
    required String username,
    required String password,
    required UserRole role,
    String? fullName,
    String? documento,
    String? telefonoFijo,
    String? telefonoMovil,
    String? correoPersonal,
    DateTime? hireDate,
  });
  Future<User> updateUser({
    required int id,
    required String username,
    required UserRole role,
    required bool isActive,
    String? newPassword,
    String? fullName,
    String? documento,
    String? telefonoFijo,
    String? telefonoMovil,
    String? correoPersonal,
    DateTime? hireDate,
  });
}

class DriftUsersRepository implements UsersRepository {
  final AppDatabase _db;

  DriftUsersRepository(this._db);

  @override
  Future<List<User>> getUsers() async {
    final rows = await _db.select(_db.usuariosTable).get();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<User> createUser({
    required String username,
    required String password,
    required UserRole role,
    String? fullName,
    String? documento,
    String? telefonoFijo,
    String? telefonoMovil,
    String? correoPersonal,
    DateTime? hireDate,
  }) async {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();

    final companion = UsuariosTableCompanion.insert(
      username: username,
      passwordHash: passwordHash,
      role: role,
      isActive: const Value(true),
      fullName: Value(fullName),
      documento: Value(documento),
      telefonoFijo: Value(telefonoFijo),
      telefonoMovil: Value(telefonoMovil),
      correoPersonal: Value(correoPersonal),
      hireDate: Value(hireDate),
    );

    final id = await _db.into(_db.usuariosTable).insert(companion);

    return User(
      id: id,
      username: username,
      role: role,
      isActive: true,
      fullName: fullName,
      documento: documento,
      telefonoFijo: telefonoFijo,
      telefonoMovil: telefonoMovil,
      correoPersonal: correoPersonal,
      hireDate: hireDate,
    );
  }

  @override
  Future<User> updateUser({
    required int id,
    required String username,
    required UserRole role,
    required bool isActive,
    String? newPassword,
    String? fullName,
    String? documento,
    String? telefonoFijo,
    String? telefonoMovil,
    String? correoPersonal,
    DateTime? hireDate,
  }) async {
    String? passwordHash;
    if (newPassword != null && newPassword.isNotEmpty) {
      passwordHash = sha256.convert(utf8.encode(newPassword)).toString();
    }

    final companion = UsuariosTableCompanion(
      username: Value(username),
      role: Value(role),
      isActive: Value(isActive),
      passwordHash: passwordHash != null ? Value(passwordHash) : const Value.absent(),
      fullName: Value(fullName),
      documento: Value(documento),
      telefonoFijo: Value(telefonoFijo),
      telefonoMovil: Value(telefonoMovil),
      correoPersonal: Value(correoPersonal),
      hireDate: Value(hireDate),
    );

    await (_db.update(_db.usuariosTable)..where((t) => t.id.equals(id))).write(companion);

    return User(
      id: id,
      username: username,
      role: role,
      isActive: isActive,
      fullName: fullName,
      documento: documento,
      telefonoFijo: telefonoFijo,
      telefonoMovil: telefonoMovil,
      correoPersonal: correoPersonal,
      hireDate: hireDate,
    );
  }

  User _mapToEntity(UsuariosTableData data) {
    return User(
      id: data.id,
      username: data.username,
      role: data.role,
      isActive: data.isActive,
      fullName: data.fullName,
      documento: data.documento,
      telefonoFijo: data.telefonoFijo,
      telefonoMovil: data.telefonoMovil,
      correoPersonal: data.correoPersonal,
      hireDate: data.hireDate,
    );
  }
}
