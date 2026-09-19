import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/drift_product_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';

/// Filtros operativos para el catálogo farmacéutico
enum ProductCatalogFilter {
  all('Todos los Productos'),
  antibiotics('Antibióticos'),
  psychotropic('Psicotrópicos (ARCSA)'),
  prescriptionRequired('Receta Retenida'),
  inactive('Inactivos');

  final String label;
  const ProductCatalogFilter(this.label);
}

/// Estado inmutable de la pantalla del catálogo de productos
class ProductCatalogState {
  final List<Product> products;
  final bool isLoading;
  final String searchQuery;
  final ProductCatalogFilter filter;
  final String? errorMessage;

  const ProductCatalogState({
    this.products = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.filter = ProductCatalogFilter.all,
    this.errorMessage,
  });

  /// Lista filtrada según búsqueda de texto y filtro de categoría ARCSA
  List<Product> get filteredProducts {
    return products.where((product) {
      // 1. Filtro por categoría operativa
      final matchesFilter = switch (filter) {
        ProductCatalogFilter.all => product.isActive,
        ProductCatalogFilter.antibiotics => product.isActive && product.esAntibiotico,
        ProductCatalogFilter.psychotropic => product.isActive && product.esPsicotropico,
        ProductCatalogFilter.prescriptionRequired => product.isActive && product.requiereReceta,
        ProductCatalogFilter.inactive => !product.isActive,
      };

      if (!matchesFilter) return false;

      // 2. Filtro por texto de búsqueda
      if (searchQuery.trim().isEmpty) return true;
      final q = searchQuery.toLowerCase();

      final matchesName = product.nombreComercial.toLowerCase().contains(q);
      final matchesActive = product.principioActivo?.toLowerCase().contains(q) ?? false;
      final matchesBarcode = product.codigoBarras?.contains(q) ?? false;

      final matchesPresentation = product.presentaciones.any((p) =>
          p.nombreDescriptivo.toLowerCase().contains(q) ||
          (p.codigoBarras?.contains(q) ?? false));

      return matchesName || matchesActive || matchesBarcode || matchesPresentation;
    }).toList();
  }

  ProductCatalogState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? searchQuery,
    ProductCatalogFilter? filter,
    String? errorMessage,
  }) {
    return ProductCatalogState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }
}

/// Controlador de negocio del catálogo de productos (SOLID: SRP)
class ProductCatalogNotifier extends StateNotifier<ProductCatalogState> {
  final IProductRepository _repository;

  ProductCatalogNotifier(this._repository) : super(const ProductCatalogState()) {
    loadProducts();
  }

  /// Carga inicial o recarga de todos los productos
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final products = await _repository.getAllProducts(onlyActive: false);
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar el catálogo de productos: $e',
      );
    }
  }

  /// Actualiza el query de búsqueda reactiva
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Cambia el filtro de categoría ARCSA
  void setFilter(ProductCatalogFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Guarda o actualiza un producto en el catálogo
  Future<bool> saveProduct(Product product) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.saveProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al guardar el producto: $e',
      );
      return false;
    }
  }

  /// Alterna el estado activo / inactivo
  Future<void> toggleProductStatus(int id, bool isActive) async {
    try {
      await _repository.toggleProductStatus(id, isActive);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al cambiar estado: $e');
    }
  }
}

/// Proveedor Riverpod para el controlador del catálogo de productos
final productCatalogProvider =
    StateNotifierProvider<ProductCatalogNotifier, ProductCatalogState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductCatalogNotifier(repository);
});
