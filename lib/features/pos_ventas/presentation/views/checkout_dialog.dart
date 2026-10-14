import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/tax_calculator.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../../clientes/domain/entities/customer.dart';

/// Modal ergonómico de cobro y liquidación final en POS (SOLID: SRP)
class CheckoutDialog extends StatefulWidget {
  final TaxCalculationResult totals;
  final Customer customer;

  const CheckoutDialog({
    super.key,
    required this.totals,
    required this.customer,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required TaxCalculationResult totals,
    required Customer customer,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CheckoutDialog(totals: totals, customer: customer),
    );
  }

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  String _metodoPago = 'efectivo'; // 'efectivo', 'tarjeta', 'transferencia'
  late TextEditingController _receivedAmountCtrl;
  final FocusNode _receivedFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _receivedAmountCtrl = TextEditingController(text: widget.totals.grandTotal.toStringAsFixed(2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _receivedFocusNode.requestFocus();
      _receivedAmountCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _receivedAmountCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _receivedAmountCtrl.dispose();
    _receivedFocusNode.dispose();
    super.dispose();
  }

  double get _receivedAmount => double.tryParse(_receivedAmountCtrl.text.replaceAll(',', '.')) ?? 0.0;
  double get _changeAmount => _receivedAmount - widget.totals.grandTotal;
  bool get _canConfirm => _metodoPago != 'efectivo' || _receivedAmount >= widget.totals.grandTotal - 0.009;

  void _onConfirm() {
    if (!_canConfirm) return;
    Navigator.of(context).pop({
      'metodoPago': _metodoPago,
      'montoRecibido': _receivedAmount,
      'cambio': _changeAmount > 0 ? _changeAmount : 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(null),
        const SingleActivator(LogicalKeyboardKey.enter): _onConfirm,
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
        elevation: 16,
        backgroundColor: colors.cardBackground,
        child: Container(
          width: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.point_of_sale, color: colors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Liquidación y Cobro',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
                          ),
                          Text(
                            'Punto de Venta / Facturación',
                            style: TextStyle(fontSize: 12, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Badge de Cliente
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.customer.isConsumidorFinal ? Icons.public : Icons.person,
                          size: 14,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.customer.nombreCompleto,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Monto Total a Cobrar Destacado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: colors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL A COBRAR:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    Text(
                      AppFormatters.currency(widget.totals.grandTotal),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Selector de Método de Pago
              Text(
                'Método de Pago:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentMethodButton('efectivo', 'Efectivo', Icons.payments_outlined, colors),
                  const SizedBox(width: 8),
                  _buildPaymentMethodButton('tarjeta', 'Tarjeta', Icons.credit_card, colors),
                  const SizedBox(width: 8),
                  _buildPaymentMethodButton('transferencia', 'Transferencia', Icons.qr_code_2, colors),
                ],
              ),
              const SizedBox(height: 16),

              // Panel Dinámico si es Efectivo
              if (_metodoPago == 'efectivo') ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Monto Recibido (\$ USD)',
                        controller: _receivedAmountCtrl,
                        focusNode: _receivedFocusNode,
                        prefixIcon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _changeAmount >= -0.009
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _changeAmount >= -0.009 ? AppColors.success : AppColors.danger,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _changeAmount >= -0.009 ? 'Vuelto a Entregar:' : 'Falta Recibir:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _changeAmount >= -0.009 ? AppColors.success : AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.currency(_changeAmount >= 0 ? _changeAmount : _changeAmount.abs()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _changeAmount >= -0.009 ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Billetes Rápidos
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('Exacto'),
                      onPressed: () {
                        setState(() {
                          _receivedAmountCtrl.text = widget.totals.grandTotal.toStringAsFixed(2);
                        });
                      },
                    ),
                    ...[5.0, 10.0, 20.0, 50.0, 100.0]
                        .where((amt) => amt >= widget.totals.grandTotal)
                        .map((amt) {
                      return ActionChip(
                        label: Text('\$${amt.toInt()}'),
                        onPressed: () {
                          setState(() {
                            _receivedAmountCtrl.text = amt.toStringAsFixed(2);
                          });
                        },
                      );
                    }),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colors.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _metodoPago == 'tarjeta'
                              ? 'Procese el cobro en el POS / Datafast / Medianet.'
                              : 'Verifique el comprobante de transferencia antes de emitir.',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Botones de Confirmación
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
                    text: 'Confirmar y Cobrar',
                    shortcutLabel: 'Enter',
                    icon: Icons.check,
                    onPressed: _canConfirm ? _onConfirm : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(String method, String label, IconData icon, AppThemeColors colors) {
    final isSelected = _metodoPago == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _metodoPago = method),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : colors.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
