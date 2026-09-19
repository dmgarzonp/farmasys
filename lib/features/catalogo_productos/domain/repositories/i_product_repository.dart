import '../entities/product.dart';

/// Contrato abstracto para el repositorio de productos y presentaciones (SOLID: DIP & ISP).
/// Permite intercambiar la implementación de Drift (SQLite) por una API REST, gRPC
/// o un Mock de pruebas sin tocar la lógica de negocio ni la interfaz de usuario.
abstract class IProductRepository {
  /// Búsqueda rápida por nombre comercial, principio activo o código de barras
  Future<List<Product>> searchProducts(String query);

  /// Obtiene todos los productos registrados (con filtro opcional de activos)
  Future<List<Product>> getAllProducts({bool onlyActive = true});

  /// Stream reactivo para observar los cambios en el catálogo en tiempo real
  Stream<List<Product>> watchAllProducts({bool onlyActive = true});

  /// Busca un producto por su código de barras directo
  Future<Product?> getProductByBarcode(String barcode);

  /// Obtiene un producto por su identificador único con todas sus presentaciones
  Future<Product?> getProductById(int id);

  /// Guarda o actualiza un producto junto con sus presentaciones comerciales
  Future<int> saveProduct(Product product);

  /// Alterna el estado activo/inactivo (borrado lógico) de un producto
  Future<void> toggleProductStatus(int id, bool isActive);

  /// Elimina una presentación específica
  Future<void> deletePresentation(int presentationId);
}
