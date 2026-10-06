import '../../../../core/database/tables/usuarios_table.dart';

class User {
  final int id;
  final String username;
  final UserRole role;
  final bool isActive;
  final String? fullName;
  final String? documento;
  final String? telefonoFijo;
  final String? telefonoMovil;
  final String? correoPersonal;
  final DateTime? hireDate;

  const User({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    this.fullName,
    this.documento,
    this.telefonoFijo,
    this.telefonoMovil,
    this.correoPersonal,
    this.hireDate,
  });

  @override
  String toString() {
    return 'User(id: $id, username: $username, role: $role, isActive: $isActive, fullName: $fullName, documento: $documento, fijo: $telefonoFijo, movil: $telefonoMovil, correo: $correoPersonal, hireDate: $hireDate)';
  }
}
