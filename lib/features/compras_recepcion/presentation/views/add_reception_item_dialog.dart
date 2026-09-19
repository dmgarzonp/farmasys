import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../catalogo_productos/domain/entities/product.dart';
import '../../domain/entities/purchase_item.dart';

/// Modal ergonómico desktop para capturar un renglón de recepción con datos ARCSA (SOLID: SRP)
class AddReceptionItemDialog extends StatefulWidget {
  final Product product;
  final ProductPresentation presentation;
  final PurchaseItem? existingItem;

  const AddReceptionItemDialog({
    super.key,
    required this.product,
    required this.presentation,
    this.existingItem,
  });

  static Future<PurchaseItem?> show(
    BuildContext context, {
    required Product product,
    required ProductPresentation presentation,
    PurchaseItem? existingItem,
  }) {
    return showDialog<PurchaseItem>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddReceptionItemDialog(
        product: product,
        presentation: presentation,
        existingItem: existingItem,
      ),
    );
  }

  @override
  State<AddReceptionItemDialog> createState() => _AddReceptionItemDialogState();
}

class _AddReceptionItemDialogState extends State<AddReceptionItemDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _loteCtrl;
  late TextEditingController _expiryCtrl;
  late TextEditingController _cajasCtrl;
  late TextEditingController _unidadesCtrl;
  late TextEditingController _costoCajaCtrl;
  late TextEditingController _tempCtrl;

  final FocusNode _loteFocusNode = FocusNode();

  late DateTime _selectedExpiry;
  bool _cumpleRegistro = true;
  bool _cumpleEmpaque = true;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _loteCtrl = TextEditingController(text: item?.lote ?? '');
    _selectedExpiry = item?.fechaVencimiento ?? DateTime.now().add(const Duration(days: 730)); // 2 años por defecto
    _expiryCtrl = TextEditingController(text: AppFormatters.date(_selectedExpiry));
    _cajasCtrl = TextEditingController(text: item != null ? item.cantidadCajas.toStringAsFixed(0) : '1');
    _unidadesCtrl = TextEditingController(text: '0');
    _costoCajaCtrl = TextEditingController(
        text: item != null ? item.costoCaja.toStringAsFixed(2) : widget.presentation.precioCompraCaja.toStringAsFixed(2));
    _tempCtrl = TextEditingController(text: item?.temperaturaRecepcion?.toStringAsFixed(1) ?? '');
    _cumpleRegistro = item?.cumpleRegistroSanitario ?? true;
    _cumpleEmpaque = item?.cumpleEmpaque ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loteFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _loteCtrl.dispose();
    _expiryCtrl.dispose();
    _cajasCtrl.dispose();
    _unidadesCtrl.dispose();
    _costoCajaCtrl.dispose();
    _tempCtrl.dispose();
    _loteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiry,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiry = picked;
        _expiryCtrl.text = AppFormatters.date(picked);
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final cajas = double.tryParse(_cajasCtrl.text.trim()) ?? 0.0;
    final unidadesSueltas = double.tryParse(_unidadesCtrl.text.trim()) ?? 0.0;
    final unidadesPorCaja = widget.presentation.unidadesPorCaja > 0 ? widget.presentation.unidadesPorCaja : 1;
    final totalUnidades = (cajas * unidadesPorCaja) + unidadesSueltas;

    final costoCaja = double.tryParse(_costoCajaCtrl.text.trim()) ?? 0.0;
    final costoUnitario = unidadesPorCaja > 0 ? (costoCaja / unidadesPorCaja) : costoCaja;
    final subtotal = (cajas * costoCaja) + (unidadesSueltas * costoUnitario);
    final temp = double.tryParse(_tempCtrl.text.trim());

    final item = PurchaseItem(
      id: widget.existingItem?.id,
      compraId: widget.existingItem?.compraId,
      presentacionId: widget.presentation.id!,
      productoNombre: widget.product.nombreComercial,
      presentacionNombre: widget.presentation.nombreDescriptivo,
      codigoBarras: widget.presentation.codigoBarras,
      lote: _loteCtrl.text.trim().toUpperCase(),
      fechaVencimiento: _selectedExpiry,
      cantidadCajas: cajas,
      cantidadUnidades: totalUnidades,
      unidadesPorCaja: unidadesPorCaja,
      costoCaja: costoCaja,
      costoUnitario: costoUnitario,
      tieneIva: widget.presentation.tieneIva,
      subtotal: subtotal,
      cumpleRegistroSanitario: _cumpleRegistro,
      cumpleEmpaque: _cumpleEmpaque,
      temperaturaRecepcion: temp,
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final unidadesPorCaja = widget.presentation.unidadesPorCaja;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(null),
        const SingleActivator(LogicalKeyboardKey.enter): _onSave,
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 16,
        backgroundColor: AppColors.cardBackground,
        child: Container(
          width: 580,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con datos del medicamento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.nombreComercial,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            '${widget.presentation.nombreDescriptivo} ($unidadesPorCaja unidades/caja) • IVA: ${widget.presentation.tieneIva ? '12%' : '0%'}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          if (widget.product.principioActivo != null)
                            Text(
                              'Principio Activo: ${widget.product.principioActivo}',
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Lote y Fecha de Vencimiento
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Número de Lote *',
                        controller: _loteCtrl,
                        focusNode: _loteFocusNode,
                        prefixIcon: Icons.qr_code_2_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Lote obligatorio';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _selectExpiryDate,
                        child: IgnorePointer(
                          child: AppTextField(
                            label: 'Vencimiento *',
                            controller: _expiryCtrl,
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Cantidad Cajas, Fracciones y Costo Caja
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Cajas Recibidas *',
                        controller: _cajasCtrl,
                        prefixIcon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          final n = double.tryParse(val ?? '');
                          if (n == null || n < 0) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Unidades Sueltas',
                        controller: _unidadesCtrl,
                        prefixIcon: Icons.grain_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Costo por Caja (\$) *',
                        controller: _costoCajaCtrl,
                        prefixIcon: Icons.attach_money_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) {
                          final n = double.tryParse(val ?? '');
                          if (n == null || n < 0) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Verificación Técnica Sanitaria ARCSA
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Control Técnico Sanitario (Normativa ARCSA)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Registro Sanitario Vigente y Legible', style: TextStyle(fontSize: 12)),
                              value: _cumpleRegistro,
                              onChanged: (val) => setState(() => _cumpleRegistro = val ?? true),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Empaque Íntegro y con Precinto', style: TextStyle(fontSize: 12)),
                              value: _cumpleEmpaque,
                              onChanged: (val) => setState(() => _cumpleEmpaque = val ?? true),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.ac_unit_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          const Text('Temp. Recepción (°C):', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 90,
                            child: AppTextField(
                              hintText: 'Ej: 4.5',
                              controller: _tempCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '(Requerido para termolábiles 2°C - 8°C)',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Acciones
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
                      text: widget.existingItem != null ? 'Actualizar Renglón' : 'Añadir a la Factura',
                      shortcutLabel: 'Enter',
                      icon: Icons.check,
                      onPressed: _onSave,
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
