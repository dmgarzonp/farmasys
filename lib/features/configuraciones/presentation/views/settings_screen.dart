import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/components.dart';
import '../controllers/settings_notifier.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Licencia Premium Activa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.success)),
                const Text('Módulo de Facturación Electrónica SRI desbloqueado.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Parámetros de Emisión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildSettingField(
                      label: 'RUC del Emisor',
                      value: ref.watch(settingsProvider).sriRuc,
                      onChanged: (val) => ref.read(settingsProvider.notifier).updateSriSettings(ruc: val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSettingField(
                      label: 'Razón Social',
                      value: ref.watch(settingsProvider).sriRazonSocial,
                      onChanged: (val) => ref.read(settingsProvider.notifier).updateSriSettings(razonSocial: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildSettingField(
                      label: 'Establecimiento (Ej. 001)',
                      value: ref.watch(settingsProvider).sriEstablecimiento,
                      onChanged: (val) => ref.read(settingsProvider.notifier).updateSriSettings(establecimiento: val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSettingField(
                      label: 'Punto Emisión (Ej. 001)',
                      value: ref.watch(settingsProvider).sriPuntoEmision,
                      onChanged: (val) => ref.read(settingsProvider.notifier).updateSriSettings(puntoEmision: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Firma Electrónica (Token/Archivo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildSettingField(
                      label: 'Ruta del Archivo .p12',
                      value: ref.watch(settingsProvider).sriFirmaPath,
                      onChanged: (val) => ref.read(settingsProvider.notifier).updateSriSettings(firmaPath: val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildSettingField(
                      label: 'Contraseña',
                      value: ref.watch(settingsProvider).sriFirmaPassword,
                      obscureText: true,
                      onChanged: (val) => ref.read(settingsProvider.notifier).updateSriSettings(firmaPassword: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ambiente SRI:', style: TextStyle(fontWeight: FontWeight.w600)),
                  DropdownButton<int>(
                    value: ref.watch(settingsProvider).sriAmbiente,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 - Pruebas')),
                      DropdownMenuItem(value: 2, child: Text('2 - Producción')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).updateSriSettings(ambiente: val);
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSettingField({
    required String label,
    required String value,
    required Function(String) onChanged,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
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
                  Navigator.pop(context);
                  AppDialogs.showSuccess(context, title: 'Licencia Activada', message: '¡Gracias por adquirir la versión Premium!');
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
