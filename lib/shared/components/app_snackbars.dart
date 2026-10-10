import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Utilidades de SnackBar estandarizadas (diseño flotante de escritorio)
class AppSnackBars {
  AppSnackBars._();

  /// Muestra un SnackBar estándar con diseño flotante
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppColors.textPrimary,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        width: 450,
        elevation: 12, // Sombra más pronunciada (efecto premium)
        dismissDirection: DismissDirection.horizontal, // Permitir deslizar para cerrar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordes un poco más redondos
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1), // Borde sutil brillante
        ),
        action: action,
        duration: duration,
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ),
    );
  }

  /// Muestra un SnackBar de éxito (verde)
  static void showSuccess(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      action: action,
      duration: duration,
    );
  }

  /// Muestra un SnackBar de error (rojo)
  static void showError(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      action: action,
      duration: duration,
    );
  }

  /// Muestra un SnackBar de advertencia (naranja)
  static void showWarning(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      action: action,
      duration: duration,
    );
  }

  /// Muestra un SnackBar de información (azul)
  static void showInfo(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.info,
      action: action,
      duration: duration,
    );
  }
}
