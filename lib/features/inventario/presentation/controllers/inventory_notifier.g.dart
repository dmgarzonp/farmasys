// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controlador de negocio del inventario y trazabilidad FEFO (SOLID: SRP)

@ProviderFor(Inventory)
final inventoryProvider = InventoryProvider._();

/// Controlador de negocio del inventario y trazabilidad FEFO (SOLID: SRP)
final class InventoryProvider
    extends $NotifierProvider<Inventory, InventoryState> {
  /// Controlador de negocio del inventario y trazabilidad FEFO (SOLID: SRP)
  InventoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inventoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inventoryHash();

  @$internal
  @override
  Inventory create() => Inventory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryState>(value),
    );
  }
}

String _$inventoryHash() => r'c2f22a750ae5d9d5866629c86a4c680be352dfd0';

/// Controlador de negocio del inventario y trazabilidad FEFO (SOLID: SRP)

abstract class _$Inventory extends $Notifier<InventoryState> {
  InventoryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InventoryState, InventoryState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<InventoryState, InventoryState>,
        InventoryState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Proveedor global reactivo para conocer el stock total disponible por presentación

@ProviderFor(availableStockMap)
final availableStockMapProvider = AvailableStockMapProvider._();

/// Proveedor global reactivo para conocer el stock total disponible por presentación

final class AvailableStockMapProvider extends $FunctionalProvider<
        AsyncValue<Map<int, double>>,
        Map<int, double>,
        Stream<Map<int, double>>>
    with $FutureModifier<Map<int, double>>, $StreamProvider<Map<int, double>> {
  /// Proveedor global reactivo para conocer el stock total disponible por presentación
  AvailableStockMapProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'availableStockMapProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$availableStockMapHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, double>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Map<int, double>> create(Ref ref) {
    return availableStockMap(ref);
  }
}

String _$availableStockMapHash() => r'633462464adca6b24d525258794f3055369c0f6e';
