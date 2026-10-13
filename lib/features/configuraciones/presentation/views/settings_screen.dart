import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../../../shared/components/components.dart';
import '../../domain/settings_state.dart';
import '../controllers/settings_notifier.dart';
import '../widgets/sri_setup_wizard_dialog.dart';
import '../../../../core/licensing/application/license_service.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/services/backup_service.dart';
import '../../domain/services/google_drive_service.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes Globales del Sistema',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Configuraciones tributarias y de negocio',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 32),

            _buildCustomizationSettings(context, ref, state, notifier, colors),
            const SizedBox(height: 24),

            XelaCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Impuestos (Ecuador)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Divider(height: 32, color: colors.borderLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Porcentaje de IVA Vigente', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Actualmente en ${(state.ivaVigente * 100).toInt()}%', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                        ],
                      ),
                      DropdownButton<double>(
                        value: state.ivaVigente,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 0.12, child: Text('12%')),
                          DropdownMenuItem(value: 0.13, child: Text('13%')),
                          DropdownMenuItem(value: 0.15, child: Text('15%')),
                          DropdownMenuItem(value: 0.16, child: Text('16%')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            notifier.updateIva(val);
                            AppDialogs.showSuccess(context, title: 'IVA Actualizado', message: 'El IVA ha sido actualizado al ${(val * 100).toInt()}%.');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            XelaCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Parámetros de Inventario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(height: 32, color: AppColors.borderLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Alerta de Vencimiento', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Días antes para mostrar alerta', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      DropdownButton<int>(
                        value: state.expirationAlertDays,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 15, child: Text('15 días')),
                          DropdownMenuItem(value: 30, child: Text('30 días')),
                          DropdownMenuItem(value: 60, child: Text('60 días')),
                          DropdownMenuItem(value: 90, child: Text('90 días')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            notifier.updateExpirationDays(val);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildBackupSettings(context, ref),
            const SizedBox(height: 24),

            Consumer(
              builder: (context, ref, child) {
                final licenseAsync = ref.watch(licenseServiceProvider);

                return XelaCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Facturación Electrónica SRI & Licencia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (licenseAsync.isLoading)
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                      const Divider(height: 32, color: AppColors.borderLight),
                      
                      licenseAsync.when(
                        data: (license) {
                          if (license.isPremium) {
                            return _buildPremiumActiveState(context, ref);
                          } else {
                            return _buildFreeState(context, ref);
                          }
                        },
                        loading: () => const Text('Cargando estado de licencia...', style: TextStyle(color: AppColors.textSecondary)),
                        error: (err, stack) => Text('Error: $err', style: const TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumActiveState(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colors = AppColors.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified, color: colors.success, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Licencia Premium Activa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.success)),
                Text('Módulo de Facturación Electrónica SRI desbloqueado.', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                 ref.read(licenseServiceProvider.notifier).deactivateLicense();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Desactivar Licencia'),
            )
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Parámetros de Configuración SRI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.primaryText)),
                  ElevatedButton.icon(
                    onPressed: () => SriSetupWizardDialog.show(context),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Configurar Parámetros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(context, colors, Icons.business_rounded, 'RUC Emisor', settings.sriRuc.isEmpty ? 'No configurado' : settings.sriRuc),
                  ),
                  Expanded(
                    child: _buildSummaryItem(context, colors, Icons.store_rounded, 'Establecimiento', settings.sriEstablecimiento.isEmpty ? 'No configurado' : '${settings.sriEstablecimiento}-${settings.sriPuntoEmision}'),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      colors,
                      Icons.cloud_sync_rounded, 
                      'Ambiente', 
                      settings.sriAmbiente == 1 ? 'Pruebas' : 'Producción',
                      color: settings.sriAmbiente == 1 ? colors.warning : colors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSummaryItem(BuildContext context, AppThemeColors colors, IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: colors.borderLight),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? colors.textPrimary)),
          ],
        )
      ],
    );
  }

  Widget _buildFreeState(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: AppColors.warning),
              const SizedBox(width: 12),
              const Text('Función Premium Bloqueada', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'La facturación electrónica con el SRI está disponible únicamente con una Licencia Premium. Activa tu licencia para emitir comprobantes electrónicos ilimitados.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.key, size: 18),
            label: const Text('Activar Licencia Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showActivationDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showActivationDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activar Licencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa tu clave de licencia Premium:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ej. PREMIUM-FARMSYS',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(licenseServiceProvider.notifier).activatePremiumLicense(controller.text);
                if (context.mounted) {
                  Navigator.pop(context); // Cierra diálogo de activación
                  SriSetupWizardDialog.show(context); // Abre el Wizard
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  AppDialogs.showError(context, title: 'Error de Activación', message: e.toString());
                }
              }
            },
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }
  Widget _buildBackupSettings(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final colors = AppColors.of(context);

    return XelaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Respaldo y Seguridad de Datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Divider(height: 32, color: colors.borderLight),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Respaldos Locales Automáticos', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Guarda una copia en "Documentos" al cerrar la caja/app', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: state.autoLocalBackupEnabled,
                activeColor: colors.primary,
                onChanged: (val) {
                  notifier.toggleAutoLocalBackup(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Respaldo en Nube Automático (Google Drive)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Sube una copia segura a internet diariamente al cerrar', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: state.autoCloudBackupEnabled,
                activeColor: colors.primary,
                onChanged: (val) async {
                  if (val) {
                    if (!googleDriveService.isAuthenticated) {
                      try {
                        final email = await googleDriveService.authenticate();
                        await notifier.linkGoogleDrive(email);
                        if (context.mounted) {
                          AppSnackBars.showSuccess(context, message: 'Sincronizado con: $email');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppDialogs.showError(context, title: 'Error de Vinculación', message: '$e');
                        }
                        await notifier.toggleAutoCloudBackup(false);
                      }
                    } else {
                      await notifier.toggleAutoCloudBackup(true);
                    }
                  } else {
                    await notifier.toggleAutoCloudBackup(false);
                  }
                },
              ),
            ],
          ),
          if (state.googleDriveEmail.isNotEmpty || (googleDriveService.isAuthenticated && (googleDriveService.currentUserEmail?.isNotEmpty ?? false))) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.cloud_done_rounded, color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cuenta vinculada a Google Drive',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('ACTIVA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.googleDriveEmail.isNotEmpty
                              ? state.googleDriveEmail
                              : (googleDriveService.currentUserEmail ?? 'Cuenta activa'),
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: colors.primaryText),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final currentEmail = state.googleDriveEmail.isNotEmpty
                          ? state.googleDriveEmail
                          : (googleDriveService.currentUserEmail ?? 'tu cuenta');

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Row(
                            children: [
                              Icon(Icons.link_off_rounded, color: AppColors.warning),
                              SizedBox(width: 10),
                              Text('Desvincular Google Drive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: Text(
                            '¿Deseas desvincular la cuenta:\n\n'
                            '• $currentEmail\n\n'
                            'Se detendrán los respaldos automáticos en la nube hasta que vincules una nueva cuenta.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Desvincular'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await googleDriveService.signOut();
                        await notifier.unlinkGoogleDrive();
                        if (context.mounted) {
                          AppSnackBars.showSuccess(
                            context,
                            message: 'Cuenta desvinculada exitosamente. Ahora puedes conectar otra cuenta.',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.link_off_rounded, size: 16),
                    label: const Text('Desvincular cuenta'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (state.autoLocalBackupEnabled || state.autoCloudBackupEnabled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.primarySurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, color: colors.primaryText, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hora del Respaldo Programado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.primaryText)),
                          const SizedBox(height: 2),
                          Text(
                            'Si el sistema queda abierto, respaldará a esta hora',
                            style: TextStyle(fontSize: 11, color: colors.textSecondary.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: state.scheduledBackupHour,
                          minute: state.scheduledBackupMinute,
                        ),
                      );
                      if (picked != null) {
                        notifier.updateScheduledBackupTime(picked.hour, picked.minute);
                      }
                    },
                    icon: const Icon(Icons.access_time_rounded, size: 16),
                    label: Text(
                      '${state.scheduledBackupHour.toString().padLeft(2, '0')}:${state.scheduledBackupMinute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Divider(height: 32, color: colors.borderLight),
          const Text('Opciones Manuales', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                  if (selectedDirectory != null) {
                    try {
                      final path = await backupService.exportToPath(selectedDirectory);
                      if (context.mounted) {
                        AppDialogs.showSuccess(context, title: 'Respaldo Exitoso', message: 'Copia guardada en:\n$path');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppDialogs.showError(context, title: 'Error de Respaldo', message: e.toString());
                      }
                    }
                  }
                },
                icon: const Icon(Icons.usb_rounded, size: 18),
                label: const Text('Respaldar a USB / Carpeta Local'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primarySurface,
                  foregroundColor: colors.primaryText,
                  elevation: 0,
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    if (!googleDriveService.isAuthenticated) {
                      final email = await googleDriveService.authenticate();
                      await notifier.linkGoogleDrive(email);
                    }
                    final dbFile = await backupService.getDatabaseFile();
                    await googleDriveService.uploadDatabaseBackup(dbFile);
                    if (context.mounted) {
                      AppDialogs.showSuccess(context, title: 'Respaldo Exitoso', message: 'La copia de seguridad se ha subido a Google Drive.');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppDialogs.showError(context, title: 'Error en la Nube', message: e.toString());
                    }
                  }
                },
                icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                label: const Text('Respaldar ahora en Drive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primarySurface,
                  foregroundColor: colors.primaryText,
                  elevation: 0,
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSettings(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
    SettingsNotifier notifier,
    AppThemeColors colors,
  ) {
    return XelaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.palette_rounded, color: colors.primaryText, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identidad y Personalización de la Farmacia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nombre comercial, apariencia visual y colores corporativos',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 32, color: colors.borderLight),

          // 1. Nombre Comercial de la Farmacia
          const Text(
            'Nombre Comercial de la Farmacia',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Este nombre se reflejará en el menú lateral, la barra de ventana y en los tickets térmicos del POS.',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 10),
          _PharmacyNameField(
            initialValue: state.pharmacyName,
            onSave: (newName) {
              notifier.updatePharmacyName(newName);
              AppDialogs.showSuccess(
                context,
                title: 'Nombre Actualizado',
                message: 'El nombre de la farmacia ahora es "$newName".',
              );
            },
          ),

          const SizedBox(height: 24),
          Divider(height: 1, color: colors.borderLight),
          const SizedBox(height: 24),

          // 2. Modo de Tema
          const Text(
            'Tema de Visualización',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona el modo visual para el trabajo diurno o turnos nocturnos.',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeModeChip(
                context: context,
                icon: Icons.light_mode_rounded,
                label: 'Modo Claro',
                isSelected: state.themeMode == ThemeMode.light,
                onTap: () => notifier.updateThemeMode(ThemeMode.light),
              ),
              const SizedBox(width: 12),
              _buildThemeModeChip(
                context: context,
                icon: Icons.dark_mode_rounded,
                label: 'Modo Oscuro',
                isSelected: state.themeMode == ThemeMode.dark,
                onTap: () => notifier.updateThemeMode(ThemeMode.dark),
              ),
              const SizedBox(width: 12),
              _buildThemeModeChip(
                context: context,
                icon: Icons.laptop_chromebook_rounded,
                label: 'Según el Sistema',
                isSelected: state.themeMode == ThemeMode.system,
                onTap: () => notifier.updateThemeMode(ThemeMode.system),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(height: 1, color: colors.borderLight),
          const SizedBox(height: 24),

          // 3. Paleta de Colores de Marca
          const Text(
            'Color Corporativo Institucional',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Elige la paleta cromática que mejor represente la identidad de tu farmacia.',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppTheme.presets.map((preset) {
              final isSelected = state.primaryColor.value == preset.primaryColor.value;
              return InkWell(
                onTap: () => notifier.updatePrimaryColor(preset.primaryColor),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? preset.primaryColor.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? preset.primaryColor : colors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: preset.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(preset.icon, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? preset.primaryColor : colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              preset.subtitle,
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colors.primaryText : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colors.primaryText : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyNameField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSave;

  const _PharmacyNameField({
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_PharmacyNameField> createState() => _PharmacyNameFieldState();
}

class _PharmacyNameFieldState extends State<_PharmacyNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _PharmacyNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: TextField(
            controller: _controller,
            style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'ej. Farmacia San José',
              filled: true,
              fillColor: colors.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.primary, width: 1.8),
              ),
              prefixIcon: Icon(Icons.storefront_rounded, size: 20, color: colors.textSecondary),
            ),
            onSubmitted: (val) => widget.onSave(val),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => widget.onSave(_controller.text),
          icon: const Icon(Icons.save_rounded, size: 16),
          label: const Text('Guardar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

