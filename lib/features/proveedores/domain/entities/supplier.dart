/// Entidad inmutable de Proveedor / Distribuidor Farmacéutico
class Supplier {
  final int? id;
  final String ruc;
  final String nombreEmpresa;
  final String? direccion;
  final String? telefonoEmpresa;
  final String? emailEmpresa;
  final String? nombreContacto;
  final String? telefonoContacto;
  final String? emailContacto;
  final String estado; // 'activo' | 'inactivo'
  final DateTime? createdAt;

  const Supplier({
    this.id,
    required this.ruc,
    required this.nombreEmpresa,
    this.direccion,
    this.telefonoEmpresa,
    this.emailEmpresa,
    this.nombreContacto,
    this.telefonoContacto,
    this.emailContacto,
    this.estado = 'activo',
    this.createdAt,
  });

  bool get isActive => estado == 'activo';

  Supplier copyWith({
    int? id,
    String? ruc,
    String? nombreEmpresa,
    String? direccion,
    String? telefonoEmpresa,
    String? emailEmpresa,
    String? nombreContacto,
    String? telefonoContacto,
    String? emailContacto,
    String? estado,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      ruc: ruc ?? this.ruc,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      direccion: direccion ?? this.direccion,
      telefonoEmpresa: telefonoEmpresa ?? this.telefonoEmpresa,
      emailEmpresa: emailEmpresa ?? this.emailEmpresa,
      nombreContacto: nombreContacto ?? this.nombreContacto,
      telefonoContacto: telefonoContacto ?? this.telefonoContacto,
      emailContacto: emailContacto ?? this.emailContacto,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ruc == other.ruc &&
          nombreEmpresa == other.nombreEmpresa;

  @override
  int get hashCode => id.hashCode ^ ruc.hashCode ^ nombreEmpresa.hashCode;
}
