import '../../../../core/utils/fefo_comparator.dart';

/// Renglón individual del carrito de compras en el Punto de Venta
class CartItem {
  final int presentacionId;
  final String productoNombre;
  final String presentacionNombre;
  final double unitPrice;
  final double quantity; // Puede ser fraccionaria (ej: 0.5 o unidades sueltas)
  final bool isFraccion;
  final double discount;
  final bool hasIva;

  // Lotes asignados por FEFO para este renglón
  final List<LotAllocation> lotAllocations;

  const CartItem({
    required this.presentacionId,
    required this.productoNombre,
    required this.presentacionNombre,
    required this.unitPrice,
    required this.quantity,
    this.isFraccion = false,
    this.discount = 0.0,
    this.hasIva = false,
    this.lotAllocations = const [],
  });

  double get grossSubtotal => unitPrice * quantity;
  double get netSubtotal => (grossSubtotal - discount).clamp(0.0, double.infinity);

  CartItem copyWith({
    double? quantity,
    double? discount,
    List<LotAllocation>? lotAllocations,
  }) {
    return CartItem(
      presentacionId: presentacionId,
      productoNombre: productoNombre,
      presentacionNombre: presentacionNombre,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      isFraccion: isFraccion,
      discount: discount ?? this.discount,
      hasIva: hasIva,
      lotAllocations: lotAllocations ?? this.lotAllocations,
    );
  }
}
