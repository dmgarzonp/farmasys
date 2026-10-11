import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/components.dart';
import '../controllers/settings_notifier.dart';
import '../widgets/sri_setup_wizard_dialog.dart';
import '../../../../core/licensing/application/license_service.dart';

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
}
