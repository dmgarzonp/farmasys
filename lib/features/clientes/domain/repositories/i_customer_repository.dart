import '../entities/customer.dart';

/// Contrato abstracto para el repositorio de clientes (SOLID: DIP)
abstract class ICustomerRepository {
  /// Obtiene la entidad fija de Consumidor Final
  Future<Customer> getConsumidorFinal();

  /// Busca clientes por cédula/RUC o nombre comercial/completo
  Future<List<Customer>> searchCustomers(String query);

  /// Obtiene un cliente por su ID interno
  Future<Customer?> getCustomerById(int id);

  /// Obtiene un cliente por su número de identificación
  Future<Customer?> getCustomerByDocument(String document);

  /// Guarda o actualiza un cliente. Retorna el ID generado o actualizado.
  Future<int> saveCustomer(Customer customer);
}
