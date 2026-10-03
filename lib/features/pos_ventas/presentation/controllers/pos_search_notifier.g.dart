// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PosSearch)
final posSearchProvider = PosSearchProvider._();

final class PosSearchProvider
    extends $NotifierProvider<PosSearch, PosSearchState> {
  PosSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'posSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$posSearchHash();

  @$internal
  @override
  PosSearch create() => PosSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PosSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosSearchState>(value),
    );
  }
}

String _$posSearchHash() => r'74bcb2748b1495759568c6cd927f80bf35ab128a';

abstract class _$PosSearch extends $Notifier<PosSearchState> {
  PosSearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PosSearchState, PosSearchState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PosSearchState, PosSearchState>,
        PosSearchState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
