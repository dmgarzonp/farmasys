import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app.dart';
import '../domain/services/backup_service.dart';
import '../domain/services/google_drive_service.dart';
import '../domain/settings_state.dart';
import '../presentation/controllers/settings_notifier.dart';

final backupSchedulerProvider = Provider<BackupScheduler>((ref) {
  final scheduler = BackupScheduler(ref);
  scheduler.init();
  ref.onDispose(() => scheduler.dispose());
  return scheduler;
});

class BackupScheduler {
  final Ref ref;
  Timer? _timer;

  BackupScheduler(this.ref);

  void init() {
    ref.listen<SettingsState>(settingsProvider, (previous, next) {
      _reschedule(next);
    }, fireImmediately: true);
  }

  void _reschedule(SettingsState state) {
    _timer?.cancel();
    if (!state.autoLocalBackupEnabled && !state.autoCloudBackupEnabled) {
      return;
    }

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      state.scheduledBackupHour,
      state.scheduledBackupMinute,
    );

    // Si la hora ya pasó hoy, se programa para mañana
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final delay = scheduled.difference(now);
    _timer = Timer(delay, () async {
      await executeScheduledBackup();
      // Reprogramar para el día siguiente
      final currentState = ref.read(settingsProvider);
      _reschedule(currentState);
    });
  }

  Future<void> executeScheduledBackup() async {
    final state = ref.read(settingsProvider);
    if (!state.autoLocalBackupEnabled && !state.autoCloudBackupEnabled) return;

    // 1. Notificación flotante informativa no intrusiva (iniciando)
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Generando respaldo automático programado...', style: TextStyle(color: Colors.white)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
        width: 450,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    try {
      if (state.autoLocalBackupEnabled) {
        await backupService.autoLocalBackup();
      }
      if (state.autoCloudBackupEnabled && googleDriveService.isAuthenticated) {
        final dbFile = await backupService.getDatabaseFile();
        await googleDriveService.uploadDatabaseBackup(dbFile);
      }

      // 2. Notificación flotante de éxito
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Respaldo automático completado con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
          width: 450,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error en respaldo programado: $e', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
          width: 450,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
