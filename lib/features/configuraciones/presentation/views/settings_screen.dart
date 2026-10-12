import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/components.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajustes Globales del Sistema',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configuraciones tributarias y de negocio',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            XelaCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Impuestos (Ecuador)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(height: 32, color: AppColors.borderLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Porcentaje de IVA Vigente', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Actualmente en ${(state.ivaVigente * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Licencia Premium Activa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
                Text('Módulo de Facturación Electrónica SRI desbloqueado.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Parámetros de Configuración SRI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
                  ElevatedButton.icon(
                    onPressed: () => SriSetupWizardDialog.show(context),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Configurar Parámetros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(Icons.business_rounded, 'RUC Emisor', settings.sriRuc.isEmpty ? 'No configurado' : settings.sriRuc),
                  ),
                  Expanded(
                    child: _buildSummaryItem(Icons.store_rounded, 'Establecimiento', settings.sriEstablecimiento.isEmpty ? 'No configurado' : '${settings.sriEstablecimiento}-${settings.sriPuntoEmision}'),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      Icons.cloud_sync_rounded, 
                      'Ambiente', 
                      settings.sriAmbiente == 1 ? 'Pruebas' : 'Producción',
                      color: settings.sriAmbiente == 1 ? AppColors.warning : AppColors.success,
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

  Widget _buildSummaryItem(IconData icon, String label, String value, {Color color = AppColors.textPrimary}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
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

    return XelaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Respaldo y Seguridad de Datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 32, color: AppColors.borderLight),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Respaldos Locales Automáticos', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Guarda una copia en "Documentos" al cerrar la caja/app', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Switch(
                value: state.autoLocalBackupEnabled,
                activeColor: AppColors.primary,
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Respaldo en Nube Automático (Google Drive)', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Sube una copia segura a internet diariamente al cerrar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Switch(
                value: state.autoCloudBackupEnabled,
                activeColor: AppColors.primary,
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
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_done_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Cuenta vinculada a Google Drive',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
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
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primaryDark),
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
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: AppColors.primaryDark, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hora del Respaldo Programado', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryDark)),
                          const SizedBox(height: 2),
                          Text(
                            'Si el sistema queda abierto, respaldará a esta hora',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.8)),
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
                      foregroundColor: AppColors.primaryDark,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 32, color: AppColors.borderLight),
          const Text('Opciones Manuales', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
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
                  backgroundColor: AppColors.primarySurface,
                  foregroundColor: AppColors.primaryDark,
                  elevation: 0,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
              ),
              const SizedBox(width: 12),
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
                  backgroundColor: AppColors.primarySurface,
                  foregroundColor: AppColors.primaryDark,
                  elevation: 0,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
