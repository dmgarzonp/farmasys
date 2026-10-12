import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/configuraciones/application/backup_scheduler.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Configuración de la aplicación raíz de FarmSys
class FarmSysApp extends ConsumerWidget {
  const FarmSysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializa el programador de respaldos en segundo plano
    ref.watch(backupSchedulerProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español nativo con formato europeo (,) para decimales
        Locale('en', 'US'), // Fallback
      ],
    );
  }
}
