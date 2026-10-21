import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_update_info.dart';
import '../../domain/services/update_checker_service.dart';

final updateCheckerServiceProvider = Provider<UpdateCheckerService>((ref) {
  return UpdateCheckerService();
});

/// Controlador Notifier de Riverpod para consultar y exponer el estado de actualizaciones
class UpdateCheckController extends Notifier<AsyncValue<AppUpdateInfo?>> {
  @override
  AsyncValue<AppUpdateInfo?> build() {
    // Comprobación inicial automática no intrusiva al iniciar la aplicación
    Future.microtask(() => checkForUpdates(force: false));
    return const AsyncData(null);
  }

  /// Comprueba si hay una nueva versión disponible en GitHub
  Future<AppUpdateInfo?> checkForUpdates({bool force = true}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(updateCheckerServiceProvider);
      final info = await service.checkForUpdates(force: force);
      state = AsyncData(info);
      return info;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Oculta el aviso de actualización durante la sesión actual
  void dismissUpdate() {
    state = const AsyncData(null);
  }
}

final updateCheckControllerProvider =
    NotifierProvider<UpdateCheckController, AsyncValue<AppUpdateInfo?>>(
  UpdateCheckController.new,
);

