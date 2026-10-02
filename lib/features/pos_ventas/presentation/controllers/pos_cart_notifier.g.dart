// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_cart_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notificador y controlador de lógica de negocio del carrito POS (SOLID: SRP)

@ProviderFor(PosCart)
final posCartProvider = PosCartProvider._();

/// Notificador y controlador de lógica de negocio del carrito POS (SOLID: SRP)
final class PosCartProvider extends $NotifierProvider<PosCart, PosCartState> {
  /// Notificador y controlador de lógica de negocio del carrito POS (SOLID: SRP)
  PosCartProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'posCartProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$posCartHash();

  @$internal
  @override
  PosCart create() => PosCart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PosCartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosCartState>(value),
    );
  }
}

String _$posCartHash() => r'29833e81261e1201068fc263a0f188e07b0cb7e8';

/// Notificador y controlador de lógica de negocio del carrito POS (SOLID: SRP)

abstract class _$PosCart extends $Notifier<PosCartState> {
  PosCartState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PosCartState, PosCartState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PosCartState, PosCartState>,
        PosCartState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
