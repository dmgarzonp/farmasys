import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

import 'features/configuraciones/domain/services/google_drive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();

  // Restaurar sesión de Google Drive si existe
  await googleDriveService.init();

  // Configuración de ventana nativa de escritorio (Windows, macOS, Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(true); // Prevenir cierre accidental automático

    const WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 800), // tamaño inicial de la ventana (ancho por alto)
      minimumSize: Size(1024, 768), // tamaño minimo de la ventana (ancho por alto)
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'FarmSys - Sistema Integral de Farmacia y POS',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FarmSysApp(),
    ),
  );
}
