// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_catalog_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controlador de negocio del catálogo de productos (SOLID: SRP)

@ProviderFor(ProductCatalog)
final productCatalogProvider = ProductCatalogProvider._();

/// Controlador de negocio del catálogo de productos (SOLID: SRP)
final class ProductCatalogProvider
    extends $NotifierProvider<ProductCatalog, ProductCatalogState> {
  /// Controlador de negocio del catálogo de productos (SOLID: SRP)
  ProductCatalogProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'productCatalogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$productCatalogHash();

  @$internal
  @override
  ProductCatalog create() => ProductCatalog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductCatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductCatalogState>(value),
    );
  }
}

String _$productCatalogHash() => r'763e7ad62c7b35691501d0d69397283f4ea61190';

/// Controlador de negocio del catálogo de productos (SOLID: SRP)

abstract class _$ProductCatalog extends $Notifier<ProductCatalogState> {
  ProductCatalogState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProductCatalogState, ProductCatalogState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProductCatalogState, ProductCatalogState>,
        ProductCatalogState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
