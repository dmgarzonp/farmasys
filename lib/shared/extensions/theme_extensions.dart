import 'package:flutter/material.dart';
import '../../core/theme/app_theme_colors.dart';
export '../../core/theme/app_theme_colors.dart';

/// Extensiones de conveniencia sobre BuildContext para acceder al sistema de temas de FarmSys
extension ThemeContextExtension on BuildContext {
  /// Acceso rápido al ThemeData activo
  ThemeData get theme => Theme.of(this);

  /// Acceso rápido al ColorScheme activo
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Acceso a los tokens de diseño institucional adaptables (Claro / Oscuro)
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ??
      (isDark ? AppThemeColors.darkFallback : AppThemeColors.lightFallback);

  /// Indica si la interfaz está resolviendo en Modo Oscuro
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
