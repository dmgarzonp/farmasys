import 'package:flutter/painting.dart';

/// Paleta de colores institucional para FarmSys
class AppColors {
  AppColors._();

  // Primarios (Esmeralda Farmacéutico)
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF047857);
  static const Color primarySurface = Color(0xFFECFDF5);

  // Secundarios e Índigo (Control y Recetas ARCSA)
  static const Color secondary = Color(0xFF4F46E5);
  static const Color secondaryLight = Color(0xFF6366F1);
  static const Color secondarySurface = Color(0xFFEEF2FF);

  // Estados de Inventario y Alertas
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Semáforo de Vencimientos de Lotes
  static const Color lotExpired = Color(0xFFFEE2E2);
  static const Color lotExpiredText = Color(0xFF991B1B);
  static const Color lotWarning = Color(0xFFFEF3C7);
  static const Color lotWarningText = Color(0xFF92400E);
  static const Color lotOptimal = Color(0xFFD1FAE5);
  static const Color lotOptimalText = Color(0xFF065F46);

  // Neutrales de Escritorio Xela
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundLight = background;
  static const Color backgroundDark = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color error = Color(0xFFEF4444);

  // Tokens de Navegación Sidebar Xela
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color sidebarBorder = Color(0xFFE2E8F0);
  static const Color sidebarActiveBg = Color(0xFFECFDF5);
  static const Color sidebarActiveText = Color(0xFF047857);
  static const Color sidebarInactiveText = Color(0xFF64748B);
  static const Color sidebarHoverBg = Color(0xFFF8FAFC);

  // Tokens de Micro-indicadores Pill Badges Xela (Fondo suave + Texto oscuro)
  static const Color pillSuccessBg = Color(0xFFDEF7EC);
  static const Color pillSuccessText = Color(0xFF03543F);

  static const Color pillWarningBg = Color(0xFFFEF08A);
  static const Color pillWarningText = Color(0xFF854D0E);

  static const Color pillDangerBg = Color(0xFFFDE8E8);
  static const Color pillDangerText = Color(0xFF9B1C1C);

  static const Color pillInfoBg = Color(0xFFE1EFFE);
  static const Color pillInfoText = Color(0xFF1E429F);

  static const Color pillPurpleBg = Color(0xFFEDEBFE);
  static const Color pillPurpleText = Color(0xFF5521B5);

  static const Color pillNeutralBg = Color(0xFFF1F5F9);
  static const Color pillNeutralText = Color(0xFF475569);
}
