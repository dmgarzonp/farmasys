import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/drift_inventory_repository.dart';
import '../../domain/entities/batch_stock.dart';
import '../../domain/repositories/i_inventory_repository.dart';

/// Filtros operativos del inventario farmacéutico
enum InventoryFilter {
  all('Todos los Lotes'),
  activeStock('Con Existencias'),
  expiringSoon('Próximos a Vencer (≤ 90 d)'),
  expired('Caducados');

  final String label;
  const InventoryFilter(this.label);
}

/// Estado inmutable de la pantalla de inventario y lotes
class InventoryState {
  final List<BatchStock> batches;
  final bool isLoading;
  final String searchQuery;
  final InventoryFilter filter;
  final String? errorMessage;

  const InventoryState({
    this.batches = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.filter = InventoryFilter.all,
    this.errorMessage,
  });

  int get totalBatches => batches.length;
  int get expiringSoonCount => batches.where((b) => b.isExpiringSoon && b.stockActual > 0).length;
  int get expiredCount => batches.where((b) => b.isExpired).length;

  /// Lotes filtrados reactivamente por búsqueda y vencimiento
  List<BatchStock> get filteredBatches {
    return batches.where((b) {
      // 1. Filtro por vigencia / estado
      final matchesFilter = switch (filter) {
        InventoryFilter.all => true,
        InventoryFilter.activeStock => b.stockActual > 0,
        InventoryFilter.expiringSoon => b.isExpiringSoon && b.stockActual > 0,
        InventoryFilter.expired => b.isExpired,
      };

      if (!matchesFilter) return false;

      // 2. Filtro por texto de búsqueda
      if (searchQuery.trim().isEmpty) return true;
      final q = searchQuery.toLowerCase();

      final matchesProduct = b.productName?.toLowerCase().contains(q) ?? false;
      final matchesLot = b.lote.toLowerCase().contains(q);
      final matchesPres = b.presentationName?.toLowerCase().contains(q) ?? false;
      final matchesLocation = b.ubicacion?.toLowerCase().contains(q) ?? false;

      return matchesProduct || matchesLot || matchesPres || matchesLocation;
    }).toList();
  }

  InventoryState copyWith({
    List<BatchStock>? batches,
    bool? isLoading,
    String? searchQuery,
    InventoryFilter? filter,
    String? errorMessage,
  }) {
    return InventoryState(
      batches: batches ?? this.batches,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }
}

/// Controlador de negocio del inventario y trazabilidad FEFO (SOLID: SRP)
class InventoryNotifier extends StateNotifier<InventoryState> {
  final IInventoryRepository _repository;

  InventoryNotifier(this._repository) : super(const InventoryState()) {
    loadBatches();
  }

  /// Carga reactiva de todos los lotes
  Future<void> loadBatches() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final batches = await _repository.getAllBatches();
      state = state.copyWith(batches: batches, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al consultar inventario: $e',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(InventoryFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Registra un nuevo ingreso de lote físico
  Future<bool> registerBatchEntry(
    BatchStock batch, {
    String? docRef,
    String? obs,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.registerBatchEntry(
        batch,
        documentoReferencia: docRef,
        observaciones: obs,
      );
      await loadBatches();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al registrar ingreso de lote: $e',
      );
      return false;
    }
  }

  /// Ajusta stock manualmente de un lote
  Future<bool> adjustStock(int batchId, double newStock, String reason) async {
    try {
      await _repository.adjustStock(batchId, newStock, reason);
      await loadBatches();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al ajustar stock: $e');
      return false;
    }
  }
}

/// Proveedor Riverpod para la gestión del inventario
final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryNotifier(repository);
});
