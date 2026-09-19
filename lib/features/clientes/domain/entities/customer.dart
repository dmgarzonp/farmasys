import '../../../../core/constants/app_constants.dart';

/// Entidad de dominio inmutable para Clientes (SOLID: SRP)
class Customer {
  final int? id;
  final String documento;
  final String tipoDocumento; // 04=RUC, 05=Cédula, 06=Pasaporte, 07=Consumidor Final
  final String nombreCompleto;
  final String? telefono;
  final String? email;
  final String? direccion;

  const Customer({
    this.id,
    required this.documento,
    this.tipoDocumento = '05',
    required this.nombreCompleto,
    this.telefono,
    this.email,
    this.direccion,
  });

  /// Factory para el cliente por defecto "Consumidor Final" del SRI
  factory Customer.consumidorFinal({int? id}) {
    return Customer(
      id: id,
      documento: AppConstants.consumidorFinalDocumento,
      tipoDocumento: '07',
      nombreCompleto: AppConstants.consumidorFinalNombre,
      direccion: 'S/D',
    );
  }

  bool get isConsumidorFinal => documento == AppConstants.consumidorFinalDocumento;

  Customer copyWith({
    int? id,
    String? documento,
    String? tipoDocumento,
    String? nombreCompleto,
    String? telefono,
    String? email,
    String? direccion,
  }) {
    return Customer(
      id: id ?? this.id,
      documento: documento ?? this.documento,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
    );
  }
}
