import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/tax_calculator.dart';
import '../../domain/entities/cart_item.dart';

/// Estado inmutable del Punto de Venta
class PosCartState {
  final List<CartItem> items;
  final TaxCalculationResult totals;
  final int? selectedClientId;
  final String? clientName;
  final bool isLoading;
  final String? errorMessage;

  const PosCartState({
    this.items = const [],
    this.totals = const TaxCalculationResult(
      subtotal0: 0.0,
      subtotalIva: 0.0,
      totalDiscount: 0.0,
      ivaAmount: 0.0,
      grandTotal: 0.0,
    ),
    this.selectedClientId,
    this.clientName,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => items.isEmpty;
  bool get canCheckout => items.isNotEmpty && !isLoading;

  PosCartState copyWith({
    List<CartItem>? items,
    TaxCalculationResult? totals,
    int? selectedClientId,
    String? clientName,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PosCartState(
      items: items ?? this.items,
      totals: totals ?? this.totals,
      selectedClientId: selectedClientId ?? this.selectedClientId,
      clientName: clientName ?? this.clientName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notificador y controlador de lógica de negocio del carrito POS (SOLID: SRP)
class PosCartNotifier extends StateNotifier<PosCartState> {
  PosCartNotifier() : super(const PosCartState());

  /// Agrega o actualiza un producto en el carrito recalculando impuestos automáticamente
  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((i) => i.presentacionId == item.presentacionId);
    final List<CartItem> updatedItems = List.from(state.items);

    if (existingIndex >= 0) {
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      updatedItems.add(item);
    }

    _recalculate(updatedItems);
  }

  /// Remueve un ítem del carrito
  void removeItem(int presentacionId) {
    final updatedItems = state.items.where((i) => i.presentacionId != presentacionId).toList();
    _recalculate(updatedItems);
  }

  /// Actualiza la cantidad solicitada
  void updateQuantity(int presentacionId, double quantity) {
    if (quantity <= 0) {
      removeItem(presentacionId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.presentacionId == presentacionId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _recalculate(updatedItems);
  }

  /// Asigna un cliente al comprobante
  void selectClient(int? clientId, String? clientName) {
    state = state.copyWith(
      selectedClientId: clientId,
      clientName: clientName,
    );
  }

  /// Vacía el carrito
  void clear() {
    state = const PosCartState();
  }

  /// Recalcula los impuestos centralizados con el TaxCalculator (DRY)
  void _recalculate(List<CartItem> items) {
    final taxableItems = items
        .map((i) => TaxableItem(
              unitPrice: i.unitPrice,
              quantity: i.quantity,
              discount: i.discount,
              isIvaExempt: !i.hasIva,
            ))
        .toList();

    final totals = TaxCalculator.calculate(taxableItems);

    state = state.copyWith(
      items: items,
      totals: totals,
      errorMessage: null,
    );
  }
}

/// Proveedor Riverpod para el carrito de compras
final posCartProvider = StateNotifierProvider<PosCartNotifier, PosCartState>((ref) {
  return PosCartNotifier();
});
