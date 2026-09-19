import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../domain/entities/cash_session.dart';

/// Diálogo modal de arqueo y cierre de caja con cálculo de diferencias en vivo (SOLID: SRP)
class CloseCashDialog extends StatefulWidget {
  final CashSession session;

  const CloseCashDialog({super.key, required this.session});

  static Future<Map<String, dynamic>?> show(BuildContext context, CashSession session) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CloseCashDialog(session: session),
    );
  }

  @override
  State<CloseCashDialog> createState() => _CloseCashDialogState();
}

class _CloseCashDialogState extends State<CloseCashDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cashCtrl;
  late TextEditingController _cardCtrl;
  late TextEditingController _transferCtrl;
  late TextEditingController _notesCtrl;

  final FocusNode _cashFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final expectedTotal = widget.session.montoInicial + widget.session.montoEsperadoEfectivo;
    _cashCtrl = TextEditingController(text: expectedTotal.toStringAsFixed(2));
    _cardCtrl = TextEditingController(text: '0.00');
    _transferCtrl = TextEditingController(text: '0.00');
    _notesCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cashFocusNode.requestFocus();
      _cashCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _cashCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    _cardCtrl.dispose();
    _transferCtrl.dispose();
    _notesCtrl.dispose();
    _cashFocusNode.dispose();
    super.dispose();
  }

  double get _expectedCash => widget.session.montoInicial + widget.session.montoEsperadoEfectivo;
  double get _enteredCash => double.tryParse(_cashCtrl.text.replaceAll(',', '.')) ?? 0.0;
  double get _cashDiff => _enteredCash - _expectedCash;

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'efectivo': _enteredCash,
      'tarjeta': double.tryParse(_cardCtrl.text.replaceAll(',', '.')) ?? 0.0,
      'transferencia': double.tryParse(_transferCtrl.text.replaceAll(',', '.')) ?? 0.0,
      'observaciones': _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasDiff = _cashDiff.abs() >= 0.01;
    final isShortage = _cashDiff < -0.009;

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
          width: 520,
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
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_clock, color: AppColors.warning, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cierre de Turno y Arqueo (Caja #${widget.session.id})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const Text(
                            'Declare los valores recaudados durante el turno',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Resumen del Sistema
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Fondo Inicial', widget.session.montoInicial),
                      _buildSummaryItem('Ventas Efectivo', widget.session.montoEsperadoEfectivo),
                      _buildSummaryItem('Total Esperado', _expectedCash, isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Inputs de Arqueo
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Efectivo en Gaveta',
                        controller: _cashCtrl,
                        focusNode: _cashFocusNode,
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Total Vouchers Tarjeta',
                        controller: _cardCtrl,
                        prefixIcon: Icons.credit_card,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'Comprobantes Transferencia / QR',
                  controller: _transferCtrl,
                  prefixIcon: Icons.account_balance,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),

                // Indicador de Diferencia (Cuadre de Caja)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: !hasDiff
                        ? AppColors.success.withValues(alpha: 0.1)
                        : (isShortage
                            ? AppColors.danger.withValues(alpha: 0.1)
                            : AppColors.info.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !hasDiff
                          ? AppColors.success
                          : (isShortage ? AppColors.danger : AppColors.info),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        !hasDiff
                            ? '✓ Caja Cuadrada Exacta'
                            : (isShortage ? '⚠️ Faltante de Efectivo:' : 'ℹ️ Sobrante de Efectivo:'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !hasDiff
                              ? AppColors.success
                              : (isShortage ? AppColors.danger : AppColors.info),
                        ),
                      ),
                      Text(
                        AppFormatters.currency(_cashDiff.abs()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: !hasDiff
                              ? AppColors.success
                              : (isShortage ? AppColors.danger : AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'Observaciones del Cierre (Opcional)',
                  controller: _notesCtrl,
                  hintText: 'Novedades del turno, billetes falsos, etc.',
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Botones
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
                      text: 'Confirmar Cierre de Caja',
                      shortcutLabel: 'Enter',
                      icon: Icons.check_circle_outline,
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

  Widget _buildSummaryItem(String label, double amount, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          AppFormatters.currency(amount),
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
