// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LicenseService)
final licenseServiceProvider = LicenseServiceProvider._();

final class LicenseServiceProvider
    extends $AsyncNotifierProvider<LicenseService, LicenseInfo> {
  LicenseServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'licenseServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$licenseServiceHash();

  @$internal
  @override
  LicenseService create() => LicenseService();
}

String _$licenseServiceHash() => r'ed8468b0d3ea48d1f07472e348243aec1a6e6c14';

abstract class _$LicenseService extends $AsyncNotifier<LicenseInfo> {
  FutureOr<LicenseInfo> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LicenseInfo>, LicenseInfo>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<LicenseInfo>, LicenseInfo>,
        AsyncValue<LicenseInfo>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
