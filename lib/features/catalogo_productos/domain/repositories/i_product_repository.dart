import '../../../../core/utils/paginated_result.dart';
import '../entities/product.dart';

/// Contrato abstracto para el repositorio de productos y presentaciones (SOLID: DIP & ISP).
/// Permite intercambiar la implementación de Drift (SQLite) por una API REST, gRPC
/// o un Mock de pruebas sin tocar la lógica de negocio ni la interfaz de usuario.
abstract class IProductRepository {
  /// Búsqueda rápida por nombre comercial, principio activo o código de barras
  Future<List<Product>> searchProducts(String query, {int limit = 50, bool onlyActive = false});

  /// Obtiene todos los productos registrados (con filtro opcional de activos)
  Future<List<Product>> getAllProducts({bool onlyActive = true});

  /// Obtiene productos de forma paginada
  Future<PaginatedResult<Product>> getProductsPaginated({
    required int limit,
    required int offset,
    String? query,
    bool? onlyActive,
    bool? onlyAntibiotic,
    bool? onlyPsychotropic,
    bool? onlyPrescriptionRequired,
    bool? onlyInactive,
  });

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

  /// Unifica un producto duplicado (origen) hacia un producto principal (destino).
  /// Mueve todos los lotes del producto de origen a la presentación principal del destino,
  /// y marca el producto de origen como inactivo.
  Future<bool> mergeProducts(int sourceProductId, int targetProductId);

  /// Elimina una presentación específica
  Future<void> deletePresentation(int presentationId);
}
