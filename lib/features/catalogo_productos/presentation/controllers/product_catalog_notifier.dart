import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/drift_product_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/i_product_repository.dart';

part 'product_catalog_notifier.g.dart';

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
  final int currentPage;
  final int pageSize;
  final int totalItems;

  const ProductCatalogState({
    this.products = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.filter = ProductCatalogFilter.all,
    this.errorMessage,
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalItems = 0,
  });

  int get totalPages => (totalItems / pageSize).ceil();

  ProductCatalogState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? searchQuery,
    ProductCatalogFilter? filter,
    String? errorMessage,
    int? currentPage,
    int? pageSize,
    int? totalItems,
  }) {
    return ProductCatalogState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      errorMessage: errorMessage, // Nullable override
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

/// Controlador de negocio del catálogo de productos (SOLID: SRP)
@riverpod
class ProductCatalog extends _$ProductCatalog {
  @override
  ProductCatalogState build() {
    Future.microtask(() => loadProducts());
    return const ProductCatalogState();
  }

  /// Carga inicial o recarga de los productos paginados
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(productRepositoryProvider);

      bool? onlyActive;
      bool? onlyAntibiotic;
      bool? onlyPsychotropic;
      bool? onlyPrescriptionRequired;
      bool? onlyInactive;
      
      switch (state.filter) {
        case ProductCatalogFilter.all:
          onlyActive = true;
          break;
        case ProductCatalogFilter.antibiotics:
          onlyActive = true;
          onlyAntibiotic = true;
          break;
        case ProductCatalogFilter.psychotropic:
          onlyActive = true;
          onlyPsychotropic = true;
          break;
        case ProductCatalogFilter.prescriptionRequired:
          onlyActive = true;
          onlyPrescriptionRequired = true;
          break;
        case ProductCatalogFilter.inactive:
          onlyInactive = true;
          break;
      }

      final offset = (state.currentPage - 1) * state.pageSize;

      final result = await repository.getProductsPaginated(
        limit: state.pageSize,
        offset: offset,
        query: state.searchQuery,
        onlyActive: onlyActive,
        onlyAntibiotic: onlyAntibiotic,
        onlyPsychotropic: onlyPsychotropic,
        onlyPrescriptionRequired: onlyPrescriptionRequired,
        onlyInactive: onlyInactive,
      );

      state = state.copyWith(
        products: result.items, 
        totalItems: result.totalCount,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar el catálogo de productos: $e',
      );
    }
  }

  /// Actualiza el query de búsqueda reactiva y recarga la página 1
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    loadProducts();
  }

  /// Cambia el filtro de categoría ARCSA y recarga la página 1
  void setFilter(ProductCatalogFilter filter) {
    state = state.copyWith(filter: filter, currentPage: 1);
    loadProducts();
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadProducts();
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      loadProducts();
    }
  }

  void setPageSize(int size) {
    state = state.copyWith(pageSize: size, currentPage: 1);
    loadProducts();
  }

  /// Guarda o actualiza un producto en el catálogo
  Future<bool> saveProduct(Product product) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.saveProduct(product);
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
      final repository = ref.read(productRepositoryProvider);
      await repository.toggleProductStatus(id, isActive);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al cambiar estado: $e');
    }
  }

  /// Absorbe uno o varios productos duplicados hacia el producto principal
  Future<bool> unifyProducts(int targetProductId, List<int> sourceProductIds) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      bool allSuccess = true;
      final repository = ref.read(productRepositoryProvider);
      for (final sourceId in sourceProductIds) {
        final success = await repository.mergeProducts(sourceId, targetProductId);
        if (!success) allSuccess = false;
      }
      await loadProducts();
      return allSuccess;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al unificar productos: $e',
      );
      return false;
    }
  }
}
