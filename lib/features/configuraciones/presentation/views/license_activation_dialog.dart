import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/licensing/application/license_service.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../widgets/sri_setup_wizard_dialog.dart';

/// Modal interactivo para visualizar el ID de máquina y activar licencias comerciales
class LicenseActivationDialog extends ConsumerStatefulWidget {
  const LicenseActivationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LicenseActivationDialog(),
    );
  }

  @override
  ConsumerState<LicenseActivationDialog> createState() =>
      _LicenseActivationDialogState();
}

class _LicenseActivationDialogState
    extends ConsumerState<LicenseActivationDialog> {
  final TextEditingController _tokenCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyMachineId(String machineId) async {
    await Clipboard.setData(ClipboardData(text: machineId));
    if (mounted) {
      AppSnackBars.showSuccess(
        context,
        message: 'ID de equipo copiado al portapapeles.',
      );
    }
  }

  Future<void> _submit() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa o pega el token de licencia.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final info = await ref
          .read(licenseServiceProvider.notifier)
          .activateLicense(token);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBars.showSuccess(
          context,
          message:
              '¡Licencia ${info.tier.name.toUpperCase()} activada exitosamente para ${info.businessName ?? "la farmacia"}!',
        );

        // Si es la primera activación y no tiene SRI configurado, sugerir el Wizard
        if (info.isPremium) {
          SriSetupWizardDialog.show(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final licenseAsync = ref.watch(licenseServiceProvider);

    final machineId = licenseAsync.asData?.value.machineId ?? 'Cargando ID...';

    return Dialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.vpn_key_rounded,
                        color: colors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activar Licencia Comercial',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Vincula tu instalación de FarmSys con tu suscripción oficial',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Paso 1: Machine ID
              Text(
                '1. ID de este Equipo (Hardware Fingerprint):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.computer_rounded,
                        size: 20, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        machineId,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    AppSecondaryButton(
                      text: 'Copiar ID',
                      icon: Icons.copy_rounded,
                      onPressed: () => _copyMachineId(machineId),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Envía este código a tu proveedor para emitir o renovar tu licencia.',
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),

              const SizedBox(height: 20),

              // Paso 2: Input Token
              Text(
                '2. Pega tu Token o Clave de Activación:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _tokenCtrl,
                maxLines: 4,
                enabled: !_isLoading,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Pega aquí el código que recibiste (ej. eyJydWM... o PREMIUM-FARMSYS)',
                  hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: colors.background,
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
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: colors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 12, color: colors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(
                    text: 'Cancelar',
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  AppPrimaryButton(
                    text: _isLoading ? 'Validando...' : 'Activar Licencia',
                    icon: _isLoading ? null : Icons.check_circle_outline,
                    onPressed: _isLoading ? null : _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
