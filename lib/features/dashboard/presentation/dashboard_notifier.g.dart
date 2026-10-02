// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardState)
final dashboardStateProvider = DashboardStateProvider._();

final class DashboardStateProvider extends $FunctionalProvider<
        AsyncValue<DashboardState>, DashboardState, FutureOr<DashboardState>>
    with $FutureModifier<DashboardState>, $FutureProvider<DashboardState> {
  DashboardStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardStateHash();

  @$internal
  @override
  $FutureProviderElement<DashboardState> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardState> create(Ref ref) {
    return dashboardState(ref);
  }
}

String _$dashboardStateHash() => r'79fd3d302633318a9adf41e8c8999a768ce4b5d5';
