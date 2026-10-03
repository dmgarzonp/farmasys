import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/drift_inventory_repository.dart';
import '../../domain/entities/batch_stock.dart';
import '../../domain/repositories/i_inventory_repository.dart';

part 'inventory_notifier.g.dart';

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
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int expiringSoonCount;
  final int expiredCount;

  const InventoryState({
    this.batches = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.filter = InventoryFilter.all,
    this.errorMessage,
    this.currentPage = 1,
    this.pageSize = 20,
    this.totalItems = 0,
    this.expiringSoonCount = 0,
    this.expiredCount = 0,
  });

  int get totalPages => (totalItems / pageSize).ceil();

  InventoryState copyWith({
    List<BatchStock>? batches,
    bool? isLoading,
    String? searchQuery,
    InventoryFilter? filter,
    String? errorMessage,
    int? currentPage,
    int? pageSize,
    int? totalItems,
    int? expiringSoonCount,
    int? expiredCount,
  }) {
    return InventoryState(
      batches: batches ?? this.batches,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      errorMessage: errorMessage, // Nullable override
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      expiringSoonCount: expiringSoonCount ?? this.expiringSoonCount,
      expiredCount: expiredCount ?? this.expiredCount,
    );
  }
}

/// Controlador de negocio del inventario y trazabilidad FEFO (SOLID: SRP)
@riverpod
class Inventory extends _$Inventory {
  @override
  InventoryState build() {
    Future.microtask(() => loadBatches());
    return const InventoryState();
  }

  /// Carga reactiva de lotes paginados
  Future<void> loadBatches() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(inventoryRepositoryProvider);

      bool onlyWithStock = false;
      bool onlyExpiringSoon = false;
      bool onlyExpired = false;

      switch (state.filter) {
        case InventoryFilter.all:
          break;
        case InventoryFilter.activeStock:
          onlyWithStock = true;
          break;
        case InventoryFilter.expiringSoon:
          onlyExpiringSoon = true;
          break;
        case InventoryFilter.expired:
          onlyExpired = true;
          break;
      }

      final offset = (state.currentPage - 1) * state.pageSize;

      final result = await repository.getBatchesPaginated(
        limit: state.pageSize,
        offset: offset,
        query: state.searchQuery,
        onlyWithStock: onlyWithStock,
        onlyExpiringSoon: onlyExpiringSoon,
        onlyExpired: onlyExpired,
      );

      final expiringResult = await repository.getBatchesPaginated(
        limit: 1, offset: 0, onlyExpiringSoon: true,
      );
      final expiredResult = await repository.getBatchesPaginated(
        limit: 1, offset: 0, onlyExpired: true,
      );

      state = state.copyWith(
        batches: result.items,
        totalItems: result.totalCount,
        expiringSoonCount: expiringResult.totalCount,
        expiredCount: expiredResult.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al consultar inventario: $e',
      );
    }
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      loadBatches();
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      loadBatches();
    }
  }

  void setPageSize(int size) {
    state = state.copyWith(pageSize: size, currentPage: 1);
    loadBatches();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    loadBatches();
  }

  void setFilter(InventoryFilter filter) {
    state = state.copyWith(filter: filter, currentPage: 1);
    loadBatches();
  }

  /// Registra un nuevo ingreso de lote físico
  Future<bool> registerBatchEntry(
    BatchStock batch, {
    String? docRef,
    String? obs,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(inventoryRepositoryProvider);
      await repository.registerBatchEntry(
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
      final repository = ref.read(inventoryRepositoryProvider);
      await repository.adjustStock(batchId, newStock, reason);
      await loadBatches();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al ajustar stock: $e');
      return false;
    }
  }

  /// Registra la salida/devolución de mercadería por caducidad o cambio
  Future<bool> processMerchandiseReturn({
    required int batchId,
    required double quantity,
    required String reasonType,
    int? supplierId,
    String? referenceDocument,
    String? observations,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(inventoryRepositoryProvider);
      await repository.registerBatchExit(
        batchId,
        quantity,
        reasonType,
        supplierId: supplierId,
        referenceDocument: referenceDocument,
        observations: observations,
      );
      await loadBatches();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al procesar devolución/salida: $e',
      );
      return false;
    }
  }
}

/// Proveedor global reactivo para conocer el stock total disponible por presentación
@riverpod
Stream<Map<int, double>> availableStockMap(Ref ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchAvailableStockMap();
}
