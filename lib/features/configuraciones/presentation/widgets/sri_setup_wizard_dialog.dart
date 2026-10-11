import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_dialogs.dart';
import '../controllers/settings_notifier.dart';

class SriSetupWizardDialog extends ConsumerStatefulWidget {
  const SriSetupWizardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // Permitir cerrar tocando fuera
      builder: (context) => const SriSetupWizardDialog(),
    );
  }

  @override
  ConsumerState<SriSetupWizardDialog> createState() => _SriSetupWizardDialogState();
}

class _SriSetupWizardDialogState extends ConsumerState<SriSetupWizardDialog> {
  int _currentStep = 0;
  
  // Paso 1: Emisor
  final _rucController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _formKeyPaso1 = GlobalKey<FormState>();

  // Paso 2: Sucursal
  final _establecimientoController = TextEditingController();
  final _puntoEmisionController = TextEditingController();
  final _formKeyPaso2 = GlobalKey<FormState>();

  // Paso 3: Firma
  final _firmaPathController = TextEditingController();
  final _firmaPasswordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKeyPaso3 = GlobalKey<FormState>();

  // Paso 4: Ambiente
  int _ambiente = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(settingsProvider);
      _rucController.text = state.sriRuc;
      _razonSocialController.text = state.sriRazonSocial;
      _establecimientoController.text = state.sriEstablecimiento;
      _puntoEmisionController.text = state.sriPuntoEmision;
      _firmaPathController.text = state.sriFirmaPath;
      _firmaPasswordController.text = state.sriFirmaPassword;
      setState(() {
        _ambiente = state.sriAmbiente;
      });
    });
  }

  @override
  void dispose() {
    _rucController.dispose();
    _razonSocialController.dispose();
    _establecimientoController.dispose();
    _puntoEmisionController.dispose();
    _firmaPathController.dispose();
    _firmaPasswordController.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    bool isValid = true;
    switch (_currentStep) {
      case 0:
        isValid = _formKeyPaso1.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _formKeyPaso2.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _formKeyPaso3.currentState?.validate() ?? false;
        break;
      case 3:
        _finishSetup();
        return;
    }

    if (isValid) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickFirmaFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['p12'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _firmaPathController.text = result.files.single.path!;
      });
    }
  }

  Future<void> _finishSetup() async {
    final notifier = ref.read(settingsProvider.notifier);
    
    await notifier.updateSriSettings(
      ruc: _rucController.text.trim(),
      razonSocial: _razonSocialController.text.trim(),
      establecimiento: _establecimientoController.text.trim(),
      puntoEmision: _puntoEmisionController.text.trim(),
      firmaPath: _firmaPathController.text.trim(),
      firmaPassword: _firmaPasswordController.text,
      ambiente: _ambiente,
    );

    if (mounted) {
      Navigator.pop(context);
      AppDialogs.showSuccess(
        context, 
        title: 'Configuración Exitosa', 
        message: 'Los parámetros del SRI han sido guardados. El sistema está listo para facturar.'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings_applications, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Asistente SRI', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Configuración de Facturación Electrónica', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Cerrar y configurar más tarde',
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            
            // Stepper Content
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: AppColors.primary),
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  controlsBuilder: (context, details) {
                    final isLastStep = _currentStep == 3;
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            child: Text(isLastStep ? 'FINALIZAR Y GUARDAR' : 'SIGUIENTE'),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: details.onStepCancel,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: const Text('ATRÁS'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('CONFIGURAR LUEGO'),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Datos del Emisor'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                      content: Form(
                        key: _formKeyPaso1,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _rucController,
                              decoration: const InputDecoration(labelText: 'RUC del Emisor', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.length != 13 ? 'El RUC debe tener 13 dígitos' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _razonSocialController,
                              decoration: const InputDecoration(labelText: 'Razón Social', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('Datos de la Sucursal'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                      content: Form(
                        key: _formKeyPaso2,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _establecimientoController,
                              decoration: const InputDecoration(labelText: 'Establecimiento (Ej. 001)', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.length != 3 ? 'Debe tener 3 dígitos' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _puntoEmisionController,
                              decoration: const InputDecoration(labelText: 'Punto de Emisión (Ej. 001)', border: OutlineInputBorder()),
                              validator: (val) => val == null || val.length != 3 ? 'Debe tener 3 dígitos' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('Firma Electrónica'),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                      content: Form(
                        key: _formKeyPaso3,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _firmaPathController,
                              decoration: InputDecoration(
                                labelText: 'Ruta del archivo .p12', 
                                border: const OutlineInputBorder(), 
                                hintText: 'C:\\Firmas\\mifirma.p12',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.folder_open),
                                  onPressed: _pickFirmaFile,
                                ),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _firmaPasswordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña de la firma',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('Ambiente de Emisión'),
                      isActive: _currentStep >= 3,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text('Selecciona el entorno del SRI donde se enviarán las facturas:', style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          RadioListTile<int>(
                            title: const Text('Ambiente de PRUEBAS (1)'),
                            subtitle: const Text('Las facturas no tienen validez tributaria real.'),
                            value: 1,
                            groupValue: _ambiente,
                            onChanged: (val) => setState(() => _ambiente = val!),
                            activeColor: AppColors.primary,
                          ),
                          RadioListTile<int>(
                            title: const Text('Ambiente de PRODUCCIÓN (2)'),
                            subtitle: const Text('Toda factura emitida será procesada legalmente.'),
                            value: 2,
                            groupValue: _ambiente,
                            onChanged: (val) => setState(() => _ambiente = val!),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
