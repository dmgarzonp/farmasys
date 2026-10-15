import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

/// Predefinición de paletas de color institucionales para FarmSys
class PharmacyColorPreset {
  final String id;
  final String name;
  final String subtitle;
  final Color primaryColor;
  final IconData icon;

  const PharmacyColorPreset({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.primaryColor,
    required this.icon,
  });
}

/// Configuración de tema visual para FarmSys (Desktop Adaptive: Modo Claro y Modo Oscuro)
class AppTheme {
  AppTheme._();

  /// Colección de 6 paletas institucionales farmacéuticas predefinidas
  static const List<PharmacyColorPreset> presets = [
    PharmacyColorPreset(
      id: 'emerald',
      name: 'Esmeralda Salud',
      subtitle: 'Clásico farmacéutico y bienestar',
      primaryColor: Color(0xFF059669),
      icon: Icons.local_pharmacy_rounded,
    ),
    PharmacyColorPreset(
      id: 'blue',
      name: 'Azul Clínico',
      subtitle: 'Confianza médica y hospitalaria',
      primaryColor: Color(0xFF0284C7),
      icon: Icons.medical_services_rounded,
    ),
    PharmacyColorPreset(
      id: 'teal',
      name: 'Turquesa Laboratorio',
      subtitle: 'Modernidad y precisión farmacéutica',
      primaryColor: Color(0xFF0D9488),
      icon: Icons.science_rounded,
    ),
    PharmacyColorPreset(
      id: 'indigo',
      name: 'Índigo Dermocosmética',
      subtitle: 'Cuidado personal y botica estética',
      primaryColor: Color(0xFF6366F1),
      icon: Icons.spa_rounded,
    ),
    PharmacyColorPreset(
      id: 'red',
      name: 'Carmín Cruz Médica',
      subtitle: 'Primeros auxilios y botica tradicional',
      primaryColor: Color(0xFFDC2626),
      icon: Icons.emergency_rounded,
    ),
    PharmacyColorPreset(
      id: 'amber',
      name: 'Ámbar Vital',
      subtitle: 'Nutrición, energía y calidez',
      primaryColor: Color(0xFFD97706),
      icon: Icons.wb_sunny_rounded,
    ),
  ];

  /// Fallback estático para compatibilidad
  static ThemeData get lightTheme => buildLightTheme(const Color(0xFF059669));

  /// Constructor reactivo de Modo Claro con color de marca personalizado
  static ThemeData buildLightTheme(Color primary) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: const Color(0xFF0F172A),
      onSurfaceVariant: const Color(0xFF64748B),
      outline: const Color(0xFFCBD5E1),
      outlineVariant: const Color(0xFFE2E8F0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      canvasColor: Colors.white,
      cardColor: Colors.white,
      visualDensity: VisualDensity.compact,
      fontFamily: 'Segoe UI',
      extensions: [
        AppThemeColors.light(primary),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFFCBD5E1);
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFFF1F5F9);
          }
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return const Color(0xFFE2E8F0);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return const Color(0xFFCBD5E1);
        }),
        trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return 0.0;
          return 1.0;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.12);
          }
          return null;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF0F172A)),
        bodyMedium: TextStyle(color: Color(0xFF0F172A)),
        bodySmall: TextStyle(color: Color(0xFF64748B)),
        titleLarge: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Constructor reactivo de Modo Oscuro con color de marca adaptado (Slate 900 / Slate 800)
  static ThemeData buildDarkTheme(Color primary) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B), // Slate 800
      onSurface: const Color(0xFFF8FAFC), // Slate 50
      onSurfaceVariant: const Color(0xFF94A3B8), // Slate 400
      outline: const Color(0xFF475569), // Slate 600
      outlineVariant: const Color(0xFF334155), // Slate 700
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      canvasColor: const Color(0xFF1E293B), // Slate 800 (para dropdowns y canvas)
      cardColor: const Color(0xFF1E293B), // Slate 800
      visualDensity: VisualDensity.compact,
      fontFamily: 'Segoe UI',
      extensions: [
        AppThemeColors.dark(primary),
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B), // Slate 800
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)), // Slate 700
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF8FAFC),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF94A3B8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: primary.withValues(alpha: 0.50)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFF475569);
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF94A3B8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0xFF0F172A);
          }
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return const Color(0xFF334155);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return const Color(0xFF475569);
        }),
        trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return 0.0;
          return 1.0;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.15);
          }
          return null;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF8FAFC)),
        bodyMedium: TextStyle(color: Color(0xFFF8FAFC)),
        bodySmall: TextStyle(color: Color(0xFF94A3B8)),
        titleLarge: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
      ),
    );
  }
}
