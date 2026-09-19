import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import 'app_buttons.dart';

/// Modal de confirmación accesible mediante teclado para escritorio
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.isDestructive = false,
  });

  /// Muestra el modal de confirmación y retorna true si fue confirmado
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(false),
        const SingleActivator(LogicalKeyboardKey.enter): () => Navigator.of(context).pop(true),
      },
      child: Focus(
        autofocus: true,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.cardBackground,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actions: [
            AppButton(
              label: cancelText,
              variant: AppButtonVariant.secondary,
              shortcutHint: 'Esc',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: confirmText,
              variant: isDestructive ? AppButtonVariant.danger : AppButtonVariant.primary,
              shortcutHint: 'Enter',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

/// Utilidades de diálogo rápidas para escritorio (SOLID: DRY)
class AppDialogs {
  AppDialogs._();

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    VoidCallback? onConfirm,
  }) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: 'Cerrar',
    );
    if (confirmed) {
      onConfirm?.call();
    }
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await AppConfirmDialog.show(
      context,
      title: title,
      message: message,
      confirmText: 'Entendido',
      isDestructive: true,
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await AppConfirmDialog.show(
      context,
      title: title,
      message: message,
      confirmText: 'Aceptar',
    );
  }
}
