// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controlador Riverpod para la sesión de caja del cajero actual (SOLID: SRP)

@ProviderFor(CashSessionNotifier)
final cashSessionProvider = CashSessionNotifierProvider._();

/// Controlador Riverpod para la sesión de caja del cajero actual (SOLID: SRP)
final class CashSessionNotifierProvider
    extends $NotifierProvider<CashSessionNotifier, CashSessionState> {
  /// Controlador Riverpod para la sesión de caja del cajero actual (SOLID: SRP)
  CashSessionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cashSessionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cashSessionNotifierHash();

  @$internal
  @override
  CashSessionNotifier create() => CashSessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CashSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CashSessionState>(value),
    );
  }
}

String _$cashSessionNotifierHash() =>
    r'99bfa27424486095a69bd579d3f448a12a0558d0';

/// Controlador Riverpod para la sesión de caja del cajero actual (SOLID: SRP)

abstract class _$CashSessionNotifier extends $Notifier<CashSessionState> {
  CashSessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CashSessionState, CashSessionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CashSessionState, CashSessionState>,
        CashSessionState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
