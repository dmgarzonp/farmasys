import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../catalogo_productos/data/repositories/drift_product_repository.dart';
import '../../../catalogo_productos/domain/entities/product.dart';

part 'pos_search_notifier.g.dart';

/// Estado inmutable de la búsqueda del POS
class PosSearchState {
  final String query;
  final List<Product> results;
  final bool isLoading;

  const PosSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
  });

  PosSearchState copyWith({
    String? query,
    List<Product>? results,
    bool? isLoading,
  }) {
    return PosSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class PosSearch extends _$PosSearch {
  @override
  PosSearchState build() {
    Future.microtask(() => search(''));
    return const PosSearchState();
  }

  Future<void> search(String query) async {
    state = state.copyWith(query: query, isLoading: true);
    try {
      final repository = ref.read(productRepositoryProvider);
      // Solo productos activos para la venta en POS
      final results = await repository.searchProducts(query, limit: 50, onlyActive: true);
      
      if (state.query == query) {
        state = state.copyWith(results: results, isLoading: false);
      }
    } catch (e) {
      if (state.query == query) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}
