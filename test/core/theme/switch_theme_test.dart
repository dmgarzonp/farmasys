import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/theme/app_theme.dart';

void main() {
  group('Verificación Quirúrgica de SwitchThemeData (Toggles FarmSys)', () {
    testWidgets('Switch activo e inactivo en Modo Claro resuelve colores contrastados sin desaparecer el thumb', (tester) async {
      const primaryColor = Color(0xFF059669);
      final lightTheme = AppTheme.buildLightTheme(primaryColor);

      bool switchValueOn = true;
      bool switchValueOff = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Switch(
                      key: const Key('switch_on'),
                      value: switchValueOn,
                      onChanged: (v) => setState(() => switchValueOn = v),
                    ),
                    Switch(
                      key: const Key('switch_off'),
                      value: switchValueOff,
                      onChanged: (v) => setState(() => switchValueOff = v),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que ambos switches se renderizan
      expect(find.byKey(const Key('switch_on')), findsOneWidget);
      expect(find.byKey(const Key('switch_off')), findsOneWidget);

      final switchTheme = lightTheme.switchTheme;

      // 1. Thumb en estado activo debe ser blanco puro (contraste sobre color primario)
      final selectedThumbColor = switchTheme.thumbColor?.resolve({WidgetState.selected});
      expect(selectedThumbColor, Colors.white);

      // 2. Track en estado activo debe ser el color primario dinámico
      final selectedTrackColor = switchTheme.trackColor?.resolve({WidgetState.selected});
      expect(selectedTrackColor, primaryColor);

      // 3. Thumb en estado inactivo debe ser blanco nítido
      final unselectedThumbColor = switchTheme.thumbColor?.resolve({});
      expect(unselectedThumbColor, Colors.white);

      // 4. Track en estado inactivo debe ser un gris slate suave (#E2E8F0)
      final unselectedTrackColor = switchTheme.trackColor?.resolve({});
      expect(unselectedTrackColor, const Color(0xFFE2E8F0));

      // 5. El contorno en estado activo debe ser transparente para no empastar el track
      final selectedOutline = switchTheme.trackOutlineColor?.resolve({WidgetState.selected});
      expect(selectedOutline, Colors.transparent);
    });

    testWidgets('Switch activo e inactivo en Modo Oscuro resuelve colores de alta visibilidad', (tester) async {
      const primaryColor = Color(0xFF059669);
      final darkTheme = AppTheme.buildDarkTheme(primaryColor);

      final switchTheme = darkTheme.switchTheme;

      // 1. Thumb en activo es blanco puro
      final selectedThumbColor = switchTheme.thumbColor?.resolve({WidgetState.selected});
      expect(selectedThumbColor, Colors.white);

      // 2. Track activo es el color primario
      final selectedTrackColor = switchTheme.trackColor?.resolve({WidgetState.selected});
      expect(selectedTrackColor, primaryColor);

      // 3. Thumb inactivo en modo oscuro es slate claro (#94A3B8)
      final unselectedThumbColor = switchTheme.thumbColor?.resolve({});
      expect(unselectedThumbColor, const Color(0xFF94A3B8));

      // 4. Track inactivo en modo oscuro es slate profundo (#334155)
      final unselectedTrackColor = switchTheme.trackColor?.resolve({});
      expect(unselectedTrackColor, const Color(0xFF334155));
    });
  });
}

