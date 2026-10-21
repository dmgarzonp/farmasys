import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../controllers/update_controller.dart';
import 'update_dialog.dart';

/// Banner visual no intrusivo que notifica la disponibilidad de una nueva versión
class UpdateBannerCard extends ConsumerWidget {
  const UpdateBannerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateCheckControllerProvider);
    final colors = context.colors;

    return updateState.maybeWhen(
      data: (info) {
        if (info == null || !info.hasUpdate) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.12),
                colors.primarySurface,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.rocket_launch_rounded, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Nueva versión v${info.latestVersion} disponible!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actualmente tienes la versión v${info.currentVersion}. Se recomienda actualizar para disfrutar de las últimas mejoras del SRI y rendimiento.',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppSecondaryButton(
                text: 'Ver y Actualizar',
                icon: Icons.download_rounded,
                onPressed: () {
                  final service = ref.read(updateCheckerServiceProvider);
                  UpdateDialog.show(context, updateInfo: info, service: service);
                },
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Ignorar por ahora',
                onPressed: () {
                  ref.read(updateCheckControllerProvider.notifier).dismissUpdate();
                },
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

