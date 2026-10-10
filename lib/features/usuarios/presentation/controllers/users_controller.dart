import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/tables/usuarios_table.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/users_repository.dart';

part 'users_controller.g.dart';

@riverpod
class UsersController extends _$UsersController {
  @override
  Future<List<User>> build() async {
    return _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    final repo = ref.read(usersRepositoryProvider);
    return await repo.getUsers();
  }

  Future<void> createUser({
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(usersRepositoryProvider);
      await repo.createUser(
        username: username,
        password: password,
        role: role,
        fullName: fullName,
        documento: documento,
        telefonoFijo: telefonoFijo,
        telefonoMovil: telefonoMovil,
        correoPersonal: correoPersonal,
        hireDate: hireDate,
      );
      return _fetchUsers();
    });
  }

  Future<void> updateUser({
    required int id,
    required String username,
    required UserRole role,
    required bool isActive,
    String? password,
    String? fullName,
    String? documento,
    String? telefonoFijo,
    String? telefonoMovil,
    String? correoPersonal,
    DateTime? hireDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(usersRepositoryProvider);
      await repo.updateUser(
        id: id,
        username: username,
        role: role,
        isActive: isActive,
        newPassword: password,
        fullName: fullName,
        documento: documento,
        telefonoFijo: telefonoFijo,
        telefonoMovil: telefonoMovil,
        correoPersonal: correoPersonal,
        hireDate: hireDate,
      );
      return _fetchUsers();
    });
  }

  Future<void> toggleUserStatus(User user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(usersRepositoryProvider);
      await repo.updateUser(
        id: user.id,
        username: user.username,
        role: user.role,
        isActive: !user.isActive, // Toggle status
      );
      return _fetchUsers();
    });
  }

  Future<void> resetPassword(User user, String tempPassword, {bool forceChange = true}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(usersRepositoryProvider);
      await repo.resetUserPassword(user.id, tempPassword, forceChange: forceChange);
      return _fetchUsers();
    });
  }
}
