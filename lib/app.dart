import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/configuraciones/application/backup_scheduler.dart';
import 'features/configuraciones/presentation/controllers/settings_notifier.dart';
import 'features/facturacion_sri/domain/services/sri_background_worker.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Configuración de la aplicación raíz de FarmSys con temas dinámicos
class FarmSysApp extends ConsumerWidget {
  const FarmSysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializa el programador de respaldos en segundo plano
    ref.watch(backupSchedulerProvider);

    // Inicializa el demonio de facturación electrónica SRI en segundo plano
    ref.watch(sriBackgroundWorkerProvider).start();

    final settings = ref.watch(settingsProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '${settings.pharmacyName} - FarmSys',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(settings.primaryColor),
      darkTheme: AppTheme.buildDarkTheme(settings.primaryColor),
      themeMode: settings.themeMode,
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
