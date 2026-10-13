import 'package:flutter/material.dart';

/// Extension de tema con tokens de diseño semánticos adaptables (Modo Claro / Modo Oscuro)
/// Basado en el sistema Xela UI Kit y paleta Slate institucional.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // Primarios y Marca
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primarySurface;
  final Color primaryText;

  // Secundarios e Índigo
  final Color secondary;
  final Color secondaryLight;
  final Color secondarySurface;

  // Estados semánticos
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  // Vencimientos de Lotes
  final Color lotExpired;
  final Color lotExpiredText;
  final Color lotWarning;
  final Color lotWarningText;
  final Color lotOptimal;
  final Color lotOptimalText;

  // Fondos y Superficies
  final Color background;
  final Color backgroundDark;
  final Color cardBackground;
  final Color inputFill;
  final Color inputReadOnlyFill;

  // Textos tipográficos
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Bordes y Divisores
  final Color border;
  final Color borderLight;
  final Color divider;

  // Navegación Sidebar
  final Color sidebarBg;
  final Color sidebarBorder;
  final Color sidebarActiveBg;
  final Color sidebarActiveText;
  final Color sidebarInactiveText;
  final Color sidebarHoverBg;

  // Badges (Pills)
  final Color pillSuccessBg;
  final Color pillSuccessText;
  final Color pillWarningBg;
  final Color pillWarningText;
  final Color pillDangerBg;
  final Color pillDangerText;
  final Color pillInfoBg;
  final Color pillInfoText;
  final Color pillPurpleBg;
  final Color pillPurpleText;
  final Color pillNeutralBg;
  final Color pillNeutralText;

  const AppThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primarySurface,
    required this.primaryText,
    required this.secondary,
    required this.secondaryLight,
    required this.secondarySurface,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.lotExpired,
    required this.lotExpiredText,
    required this.lotWarning,
    required this.lotWarningText,
    required this.lotOptimal,
    required this.lotOptimalText,
    required this.background,
    required this.backgroundDark,
    required this.cardBackground,
    required this.inputFill,
    required this.inputReadOnlyFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.sidebarBg,
    required this.sidebarBorder,
    required this.sidebarActiveBg,
    required this.sidebarActiveText,
    required this.sidebarInactiveText,
    required this.sidebarHoverBg,
    required this.pillSuccessBg,
    required this.pillSuccessText,
    required this.pillWarningBg,
    required this.pillWarningText,
    required this.pillDangerBg,
    required this.pillDangerText,
    required this.pillInfoBg,
    required this.pillInfoText,
    required this.pillPurpleBg,
    required this.pillPurpleText,
    required this.pillNeutralBg,
    required this.pillNeutralText,
  });

  /// Superficie o tarjeta principal
  Color get surface => cardBackground;

  /// Alias de error semántico compatible con convenciones de Flutter
  Color get error => danger;

  /// Configuración de tokens para Modo Claro
  factory AppThemeColors.light(Color primaryColor) {
    return AppThemeColors(
      primary: primaryColor,
      primaryLight: const Color(0xFF10B981),
      primaryDark: const Color(0xFF047857),
      primarySurface: const Color(0xFFECFDF5),
      primaryText: const Color(0xFF047857),
      secondary: const Color(0xFF4F46E5),
      secondaryLight: const Color(0xFF6366F1),
      secondarySurface: const Color(0xFFEEF2FF),
      success: const Color(0xFF10B981),
      warning: const Color(0xFFF59E0B),
      danger: const Color(0xFFEF4444),
      info: const Color(0xFF3B82F6),
      lotExpired: const Color(0xFFFEE2E2),
      lotExpiredText: const Color(0xFF991B1B),
      lotWarning: const Color(0xFFFEF3C7),
      lotWarningText: const Color(0xFF92400E),
      lotOptimal: const Color(0xFFD1FAE5),
      lotOptimalText: const Color(0xFF065F46),
      background: const Color(0xFFF8FAFC), // Slate 50
      backgroundDark: const Color(0xFFF1F5F9), // Slate 100
      cardBackground: const Color(0xFFFFFFFF),
      inputFill: const Color(0xFFFFFFFF),
      inputReadOnlyFill: const Color(0xFFF1F5F9),
      textPrimary: const Color(0xFF0F172A), // Slate 900
      textSecondary: const Color(0xFF64748B), // Slate 500
      textMuted: const Color(0xFF94A3B8), // Slate 400
      border: const Color(0xFFE2E8F0), // Slate 200
      borderLight: const Color(0xFFE2E8F0),
      divider: const Color(0xFFF1F5F9),
      sidebarBg: const Color(0xFFFFFFFF),
      sidebarBorder: const Color(0xFFE2E8F0),
      sidebarActiveBg: const Color(0xFFECFDF5),
      sidebarActiveText: const Color(0xFF047857),
      sidebarInactiveText: const Color(0xFF64748B),
      sidebarHoverBg: const Color(0xFFF8FAFC),
      pillSuccessBg: const Color(0xFFDEF7EC),
      pillSuccessText: const Color(0xFF03543F),
      pillWarningBg: const Color(0xFFFEF08A),
      pillWarningText: const Color(0xFF854D0E),
      pillDangerBg: const Color(0xFFFDE8E8),
      pillDangerText: const Color(0xFF9B1C1C),
      pillInfoBg: const Color(0xFFE1EFFE),
      pillInfoText: const Color(0xFF1E429F),
      pillPurpleBg: const Color(0xFFEDEBFE),
      pillPurpleText: const Color(0xFF5521B5),
      pillNeutralBg: const Color(0xFFF1F5F9),
      pillNeutralText: const Color(0xFF475569),
    );
  }

  /// Configuración de tokens para Modo Oscuro (Slate 900 / Slate 800)
  factory AppThemeColors.dark(Color primaryColor) {
    return AppThemeColors(
      primary: primaryColor,
      primaryLight: const Color(0xFF34D399),
      primaryDark: const Color(0xFF059669),
      primarySurface: primaryColor.withValues(alpha: 0.16),
      primaryText: const Color(0xFF6EE7B7),
      secondary: const Color(0xFF6366F1),
      secondaryLight: const Color(0xFF818CF8),
      secondarySurface: const Color(0xFF312E81).withValues(alpha: 0.35),
      success: const Color(0xFF34D399),
      warning: const Color(0xFFFBBF24),
      danger: const Color(0xFFF87171),
      info: const Color(0xFF60A5FA),
      lotExpired: const Color(0xFF450A0A),
      lotExpiredText: const Color(0xFFFCA5A5),
      lotWarning: const Color(0xFF451A03),
      lotWarningText: const Color(0xFFFDE68A),
      lotOptimal: const Color(0xFF064E3B),
      lotOptimalText: const Color(0xFF6EE7B7),
      background: const Color(0xFF0F172A), // Slate 900
      backgroundDark: const Color(0xFF0B132B), // Slate 950
      cardBackground: const Color(0xFF1E293B), // Slate 800
      inputFill: const Color(0xFF1E293B), // Slate 800
      inputReadOnlyFill: const Color(0xFF0F172A), // Slate 900
      textPrimary: const Color(0xFFF8FAFC), // Slate 50 (Alto contraste)
      textSecondary: const Color(0xFF94A3B8), // Slate 400 (Legibilidad WCAG AA)
      textMuted: const Color(0xFF64748B), // Slate 500
      border: const Color(0xFF334155), // Slate 700
      borderLight: const Color(0xFF334155),
      divider: const Color(0xFF334155),
      sidebarBg: const Color(0xFF0F172A), // Slate 900
      sidebarBorder: const Color(0xFF1E293B), // Slate 800
      sidebarActiveBg: primaryColor.withValues(alpha: 0.20),
      sidebarActiveText: const Color(0xFF6EE7B7),
      sidebarInactiveText: const Color(0xFF94A3B8),
      sidebarHoverBg: const Color(0xFF1E293B),
      pillSuccessBg: const Color(0xFF064E3B).withValues(alpha: 0.50),
      pillSuccessText: const Color(0xFF34D399),
      pillWarningBg: const Color(0xFF78350F).withValues(alpha: 0.50),
      pillWarningText: const Color(0xFFFBBF24),
      pillDangerBg: const Color(0xFF7F1D1D).withValues(alpha: 0.50),
      pillDangerText: const Color(0xFFF87171),
      pillInfoBg: const Color(0xFF1E3A8A).withValues(alpha: 0.50),
      pillInfoText: const Color(0xFF60A5FA),
      pillPurpleBg: const Color(0xFF581C87).withValues(alpha: 0.50),
      pillPurpleText: const Color(0xFFC084FC),
      pillNeutralBg: const Color(0xFF334155),
      pillNeutralText: const Color(0xFFCBD5E1),
    );
  }

  static AppThemeColors get lightFallback => AppThemeColors.light(const Color(0xFF059669));
  static AppThemeColors get darkFallback => AppThemeColors.dark(const Color(0xFF059669));

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? primarySurface,
    Color? primaryText,
    Color? secondary,
    Color? secondaryLight,
    Color? secondarySurface,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? lotExpired,
    Color? lotExpiredText,
    Color? lotWarning,
    Color? lotWarningText,
    Color? lotOptimal,
    Color? lotOptimalText,
    Color? background,
    Color? backgroundDark,
    Color? cardBackground,
    Color? inputFill,
    Color? inputReadOnlyFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? borderLight,
    Color? divider,
    Color? sidebarBg,
    Color? sidebarBorder,
    Color? sidebarActiveBg,
    Color? sidebarActiveText,
    Color? sidebarInactiveText,
    Color? sidebarHoverBg,
    Color? pillSuccessBg,
    Color? pillSuccessText,
    Color? pillWarningBg,
    Color? pillWarningText,
    Color? pillDangerBg,
    Color? pillDangerText,
    Color? pillInfoBg,
    Color? pillInfoText,
    Color? pillPurpleBg,
    Color? pillPurpleText,
    Color? pillNeutralBg,
    Color? pillNeutralText,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySurface: primarySurface ?? this.primarySurface,
      primaryText: primaryText ?? this.primaryText,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      lotExpired: lotExpired ?? this.lotExpired,
      lotExpiredText: lotExpiredText ?? this.lotExpiredText,
      lotWarning: lotWarning ?? this.lotWarning,
      lotWarningText: lotWarningText ?? this.lotWarningText,
      lotOptimal: lotOptimal ?? this.lotOptimal,
      lotOptimalText: lotOptimalText ?? this.lotOptimalText,
      background: background ?? this.background,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      cardBackground: cardBackground ?? this.cardBackground,
      inputFill: inputFill ?? this.inputFill,
      inputReadOnlyFill: inputReadOnlyFill ?? this.inputReadOnlyFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      divider: divider ?? this.divider,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      sidebarActiveBg: sidebarActiveBg ?? this.sidebarActiveBg,
      sidebarActiveText: sidebarActiveText ?? this.sidebarActiveText,
      sidebarInactiveText: sidebarInactiveText ?? this.sidebarInactiveText,
      sidebarHoverBg: sidebarHoverBg ?? this.sidebarHoverBg,
      pillSuccessBg: pillSuccessBg ?? this.pillSuccessBg,
      pillSuccessText: pillSuccessText ?? this.pillSuccessText,
      pillWarningBg: pillWarningBg ?? this.pillWarningBg,
      pillWarningText: pillWarningText ?? this.pillWarningText,
      pillDangerBg: pillDangerBg ?? this.pillDangerBg,
      pillDangerText: pillDangerText ?? this.pillDangerText,
      pillInfoBg: pillInfoBg ?? this.pillInfoBg,
      pillInfoText: pillInfoText ?? this.pillInfoText,
      pillPurpleBg: pillPurpleBg ?? this.pillPurpleBg,
      pillPurpleText: pillPurpleText ?? this.pillPurpleText,
      pillNeutralBg: pillNeutralBg ?? this.pillNeutralBg,
      pillNeutralText: pillNeutralText ?? this.pillNeutralText,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryLight: Color.lerp(secondaryLight, other.secondaryLight, t)!,
      secondarySurface: Color.lerp(secondarySurface, other.secondarySurface, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      lotExpired: Color.lerp(lotExpired, other.lotExpired, t)!,
      lotExpiredText: Color.lerp(lotExpiredText, other.lotExpiredText, t)!,
      lotWarning: Color.lerp(lotWarning, other.lotWarning, t)!,
      lotWarningText: Color.lerp(lotWarningText, other.lotWarningText, t)!,
      lotOptimal: Color.lerp(lotOptimal, other.lotOptimal, t)!,
      lotOptimalText: Color.lerp(lotOptimalText, other.lotOptimalText, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputReadOnlyFill: Color.lerp(inputReadOnlyFill, other.inputReadOnlyFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      sidebarActiveBg: Color.lerp(sidebarActiveBg, other.sidebarActiveBg, t)!,
      sidebarActiveText: Color.lerp(sidebarActiveText, other.sidebarActiveText, t)!,
      sidebarInactiveText: Color.lerp(sidebarInactiveText, other.sidebarInactiveText, t)!,
      sidebarHoverBg: Color.lerp(sidebarHoverBg, other.sidebarHoverBg, t)!,
      pillSuccessBg: Color.lerp(pillSuccessBg, other.pillSuccessBg, t)!,
      pillSuccessText: Color.lerp(pillSuccessText, other.pillSuccessText, t)!,
      pillWarningBg: Color.lerp(pillWarningBg, other.pillWarningBg, t)!,
      pillWarningText: Color.lerp(pillWarningText, other.pillWarningText, t)!,
      pillDangerBg: Color.lerp(pillDangerBg, other.pillDangerBg, t)!,
      pillDangerText: Color.lerp(pillDangerText, other.pillDangerText, t)!,
      pillInfoBg: Color.lerp(pillInfoBg, other.pillInfoBg, t)!,
      pillInfoText: Color.lerp(pillInfoText, other.pillInfoText, t)!,
      pillPurpleBg: Color.lerp(pillPurpleBg, other.pillPurpleBg, t)!,
      pillPurpleText: Color.lerp(pillPurpleText, other.pillPurpleText, t)!,
      pillNeutralBg: Color.lerp(pillNeutralBg, other.pillNeutralBg, t)!,
      pillNeutralText: Color.lerp(pillNeutralText, other.pillNeutralText, t)!,
    );
  }
}
