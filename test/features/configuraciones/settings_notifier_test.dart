import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmsys/core/theme/app_theme.dart';
import 'package:farmsys/features/configuraciones/data/settings_repository.dart';
import 'package:farmsys/features/configuraciones/presentation/controllers/settings_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SettingsRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = SettingsRepository();
    container = ProviderContainer();
    await container.read(settingsProvider.notifier).reloadSettings();
  });

  tearDown(() {
    container.dispose();
  });

  group('Personalización de Farmacia y Ajustes Visuales', () {
    test('Valores por defecto de identidad y tema', () {
      final state = container.read(settingsProvider);
      expect(state.pharmacyName, equals('Mi Farmacia'));
      expect(state.themeMode, equals(ThemeMode.system));
      expect(state.primaryColor, equals(AppTheme.presets[0].primaryColor));
    });

    test('Actualización reactiva y persistencia del nombre de farmacia', () async {
      final notifier = container.read(settingsProvider.notifier);
      await notifier.updatePharmacyName('Farmacia San José');

      expect(container.read(settingsProvider).pharmacyName, equals('Farmacia San José'));

      // Verificar persistencia en el repositorio
      final persistedName = await repository.getPharmacyName();
      expect(persistedName, equals('Farmacia San José'));
    });

    test('Actualización reactiva y persistencia del modo de tema', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateThemeMode(ThemeMode.dark);
      expect(container.read(settingsProvider).themeMode, equals(ThemeMode.dark));
      expect(await repository.getThemeMode(), equals('dark'));

      await notifier.updateThemeMode(ThemeMode.light);
      expect(container.read(settingsProvider).themeMode, equals(ThemeMode.light));
      expect(await repository.getThemeMode(), equals('light'));
    });

    test('Actualización reactiva y persistencia de la paleta institucional', () async {
      final notifier = container.read(settingsProvider.notifier);
      final indigoColor = AppTheme.presets[3].primaryColor;

      await notifier.updatePrimaryColor(indigoColor);
      expect(container.read(settingsProvider).primaryColor, equals(indigoColor));

      final persistedColor = await repository.getPrimaryColor();
      expect(persistedColor, equals(indigoColor.value));
    });

    test('AppTheme genera temas claros y oscuros válidos con semilla personalizada', () {
      final seedColor = AppTheme.presets[1].primaryColor; // Azul Clínico
      final lightTheme = AppTheme.buildLightTheme(seedColor);
      final darkTheme = AppTheme.buildDarkTheme(seedColor);

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(lightTheme.useMaterial3, isTrue);
      expect(darkTheme.useMaterial3, isTrue);
      expect(lightTheme.colorScheme.primary, isNotNull);
      expect(darkTheme.colorScheme.primary, isNotNull);
    });
  });
}
