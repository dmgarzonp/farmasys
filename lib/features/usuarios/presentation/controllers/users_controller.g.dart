// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UsersController)
final usersControllerProvider = UsersControllerProvider._();

final class UsersControllerProvider
    extends $AsyncNotifierProvider<UsersController, List<User>> {
  UsersControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'usersControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$usersControllerHash();

  @$internal
  @override
  UsersController create() => UsersController();
}

String _$usersControllerHash() => r'734d0f2aa10fcec4bf033225d6849c5611b04a2a';

abstract class _$UsersController extends $AsyncNotifier<List<User>> {
  FutureOr<List<User>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<User>>, List<User>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<User>>, List<User>>,
        AsyncValue<List<User>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
