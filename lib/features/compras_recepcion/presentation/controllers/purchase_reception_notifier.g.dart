// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_reception_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier que controla la lógica de recepción de mercadería y cuadre de factura

@ProviderFor(PurchaseReception)
final purchaseReceptionProvider = PurchaseReceptionProvider._();

/// Notifier que controla la lógica de recepción de mercadería y cuadre de factura
final class PurchaseReceptionProvider
    extends $NotifierProvider<PurchaseReception, PurchaseReceptionState> {
  /// Notifier que controla la lógica de recepción de mercadería y cuadre de factura
  PurchaseReceptionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'purchaseReceptionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$purchaseReceptionHash();

  @$internal
  @override
  PurchaseReception create() => PurchaseReception();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseReceptionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseReceptionState>(value),
    );
  }
}

String _$purchaseReceptionHash() => r'548ddbe82f368c7df965887bd6d8a72afd5deac6';

/// Notifier que controla la lógica de recepción de mercadería y cuadre de factura

abstract class _$PurchaseReception extends $Notifier<PurchaseReceptionState> {
  PurchaseReceptionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PurchaseReceptionState, PurchaseReceptionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PurchaseReceptionState, PurchaseReceptionState>,
        PurchaseReceptionState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(pendingPurchases)
final pendingPurchasesProvider = PendingPurchasesProvider._();

final class PendingPurchasesProvider extends $FunctionalProvider<
        AsyncValue<List<PurchaseInvoice>>,
        List<PurchaseInvoice>,
        FutureOr<List<PurchaseInvoice>>>
    with
        $FutureModifier<List<PurchaseInvoice>>,
        $FutureProvider<List<PurchaseInvoice>> {
  PendingPurchasesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingPurchasesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingPurchasesHash();

  @$internal
  @override
  $FutureProviderElement<List<PurchaseInvoice>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseInvoice>> create(Ref ref) {
    return pendingPurchases(ref);
  }
}

String _$pendingPurchasesHash() => r'70572da8c62ea45443570e929e0601ba08c0981b';
