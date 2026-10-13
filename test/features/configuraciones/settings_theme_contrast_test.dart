import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmsys/core/theme/app_theme.dart';
import 'package:farmsys/core/theme/app_theme_colors.dart';
import 'package:farmsys/shared/extensions/theme_extensions.dart';
import 'package:farmsys/features/configuraciones/presentation/controllers/settings_notifier.dart';
import 'package:farmsys/features/configuraciones/presentation/views/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pharmacy_name': 'Farmacia Central',
      'theme_mode': 'dark',
      'primary_color': 0xFF059669,
    });
  });

  group('Verificación de Tokens de Contraste y Sistema Slate', () {
    test('AppThemeColors modo oscuro cumple especificación Slate institucional', () {
      final darkColors = AppThemeColors.dark(const Color(0xFF059669));

      // Fondos Slate
      expect(darkColors.background, equals(const Color(0xFF0F172A))); // Slate 900
      expect(darkColors.cardBackground, equals(const Color(0xFF1E293B))); // Slate 800
      expect(darkColors.surface, equals(const Color(0xFF1E293B)));

      // Bordes y divisores Slate
      expect(darkColors.border, equals(const Color(0xFF334155))); // Slate 700
      expect(darkColors.divider, equals(const Color(0xFF334155)));

      // Tipografía de alto contraste Slate
      expect(darkColors.textPrimary, equals(const Color(0xFFF8FAFC))); // Slate 50
      expect(darkColors.textSecondary, equals(const Color(0xFF94A3B8))); // Slate 400
      expect(darkColors.textMuted, equals(const Color(0xFF64748B))); // Slate 500

      // Inputs en modo oscuro
      expect(darkColors.inputFill, equals(const Color(0xFF1E293B))); // Slate 800
    });

    test('AppThemeColors modo claro cumple especificación', () {
      final lightColors = AppThemeColors.light(const Color(0xFF059669));

      expect(lightColors.background, equals(const Color(0xFFF8FAFC)));
      expect(lightColors.cardBackground, equals(const Color(0xFFFFFFFF)));
      expect(lightColors.textPrimary, equals(const Color(0xFF0F172A)));
      expect(lightColors.border, equals(const Color(0xFFE2E8F0)));
      expect(lightColors.inputFill, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('ThemeContextExtension resuelve AppThemeColors en árbol de widgets', (tester) async {
      late AppThemeColors resolvedColors;
      late bool isDarkResolved;

      final darkTheme = AppTheme.buildDarkTheme(const Color(0xFF059669));

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Builder(
            builder: (context) {
              resolvedColors = context.colors;
              isDarkResolved = context.isDark;
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      expect(isDarkResolved, isTrue);
      expect(resolvedColors.background, equals(const Color(0xFF0F172A)));
      expect(resolvedColors.textPrimary, equals(const Color(0xFFF8FAFC)));
      expect(resolvedColors.cardBackground, equals(const Color(0xFF1E293B)));
    });

    testWidgets('SettingsScreen renderiza chips de tema y componentes adaptables en Modo Oscuro', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      await container.read(settingsProvider.notifier).reloadSettings();

      final darkTheme = AppTheme.buildDarkTheme(const Color(0xFF059669));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que los chips de modo de tema existen
      expect(find.text('Modo Oscuro'), findsOneWidget);
      expect(find.text('Modo Claro'), findsOneWidget);
      expect(find.text('Según el Sistema'), findsOneWidget);

      // Verificar que el título de sección de identidad y personalización existe
      expect(find.text('Identidad y Personalización de la Farmacia'), findsOneWidget);
      expect(find.text('Tema de Visualización'), findsOneWidget);

      // Verificar que el campo de nombre de farmacia se renderiza
      expect(find.text('Nombre Comercial de la Farmacia'), findsOneWidget);

      container.dispose();
    });
  });
}
