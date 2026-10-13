import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../extensions/theme_extensions.dart';

enum AppButtonVariant { primary, secondary, success, danger, ghost }

/// Botón estandarizado de escritorio con soporte de atajos de teclado visuales (SOLID: DRY)
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final String? shortcutHint; // Ej: "F1", "Enter", "Esc"
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.shortcutHint,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final Color bgColor = _getBackgroundColor(colors);
    final Color fgColor = _getForegroundColor(colors);

    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 16, color: fgColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: fgColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (shortcutHint != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: fgColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcutHint!,
              style: TextStyle(
                color: fgColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 38,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: variant == AppButtonVariant.secondary
                ? BorderSide(color: colors.border)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    );
  }

  Color _getBackgroundColor(AppThemeColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colors.primary;
      case AppButtonVariant.secondary:
        return colors.cardBackground;
      case AppButtonVariant.success:
        return colors.success;
      case AppButtonVariant.danger:
        return colors.danger;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(AppThemeColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.success:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
        return colors.textPrimary;
      case AppButtonVariant.ghost:
        return colors.textSecondary;
    }
  }
}

/// Botón primario preconfigurado para escritorio
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? shortcutLabel;
  final bool isLoading;
  final bool fullWidth;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.shortcutLabel,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      icon: icon,
      shortcutHint: shortcutLabel,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }
}

/// Botón secundario preconfigurado para escritorio
class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? shortcutLabel;
  final bool isLoading;
  final bool fullWidth;

  const AppSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.shortcutLabel,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: text,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      icon: icon,
      shortcutHint: shortcutLabel,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }
}

