import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';

/// Diálogo modal ergonómico de escritorio para apertura de turno de caja (SOLID: SRP)
class OpenCashDialog extends StatefulWidget {
  const OpenCashDialog({super.key});

  static Future<double?> show(BuildContext context) {
    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const OpenCashDialog(),
    );
  }

  @override
  State<OpenCashDialog> createState() => _OpenCashDialogState();
}

class _OpenCashDialogState extends State<OpenCashDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: '50.00');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
      _amountCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _amountCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(null),
        const SingleActivator(LogicalKeyboardKey.enter): _onConfirm,
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 16,
        backgroundColor: AppColors.cardBackground,
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.point_of_sale, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apertura de Turno de Caja',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Ingrese el fondo de cambio inicial en efectivo',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo de monto inicial
                AppTextField(
                  label: 'Fondo Inicial de Efectivo (\$ USD)',
                  controller: _amountCtrl,
                  focusNode: _amountFocusNode,
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Ingrese un monto válido';
                    final parsed = double.tryParse(val.replaceAll(',', '.'));
                    if (parsed == null || parsed < 0) return 'Ingrese un valor numérico positivo';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Botones de monto rápido sugerido
                Wrap(
                  spacing: 8,
                  children: [20.0, 50.0, 100.0].map((sug) {
                    return ActionChip(
                      label: Text('\$${sug.toStringAsFixed(2)}'),
                      onPressed: () {
                        setState(() {
                          _amountCtrl.text = sug.toStringAsFixed(2);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppSecondaryButton(
                      text: 'Cancelar',
                      shortcutLabel: 'Esc',
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                    const SizedBox(width: 12),
                    AppPrimaryButton(
                      text: 'Abrir Turno',
                      shortcutLabel: 'Enter',
                      icon: Icons.check,
                      onPressed: _onConfirm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
