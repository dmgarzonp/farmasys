import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../catalogo_productos/presentation/controllers/product_catalog_notifier.dart';
import '../../domain/entities/batch_stock.dart';

/// Modal de escritorio para registrar el ingreso de mercadería física con lote y fecha de vencimiento (SOLID: SRP)
class BatchEntryDialog extends ConsumerStatefulWidget {
  const BatchEntryDialog({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const BatchEntryDialog(),
    );
  }

  @override
  ConsumerState<BatchEntryDialog> createState() => _BatchEntryDialogState();
}

class _BatchEntryDialogState extends ConsumerState<BatchEntryDialog> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedPresentacionId;
  String? _selectedProductName;

  late TextEditingController _lotCodeCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _costPriceCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _docRefCtrl;

  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    _lotCodeCtrl = TextEditingController();
    _quantityCtrl = TextEditingController(text: '10');
    _costPriceCtrl = TextEditingController(text: '0.00');
    _locationCtrl = TextEditingController(text: 'Estante A-1');
    _docRefCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _lotCodeCtrl.dispose();
    _quantityCtrl.dispose();
    _costPriceCtrl.dispose();
    _locationCtrl.dispose();
    _docRefCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: 'Seleccionar Fecha de Caducidad del Lote',
    );

    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPresentacionId == null) {
      AppSnackBars.showError(
        context,
        message: 'Por favor seleccione un medicamento del catálogo',
      );
      return;
    }

    final batch = BatchStock(
      presentacionId: _selectedPresentacionId!,
      productName: _selectedProductName,
      lote: _lotCodeCtrl.text.trim().toUpperCase(),
      fechaVencimiento: _expirationDate,
      fechaIngreso: DateTime.now(),
      stockActual: double.tryParse(_quantityCtrl.text) ?? 0.0,
      precioCompraUnitario: double.tryParse(_costPriceCtrl.text) ?? 0.0,
      ubicacion: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : null,
    );

    Navigator.of(context).pop({
      'batch': batch,
      'docRef': _docRefCtrl.text.trim().isNotEmpty ? _docRefCtrl.text.trim() : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(productCatalogProvider);
    final products = catalogState.products.where((p) => p.isActive && p.presentaciones.isNotEmpty).toList();

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => Navigator.of(context).pop()),
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          backgroundColor: AppColors.cardBackground,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_box_outlined, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Ingreso de Mercadería y Lote Físico',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textMuted),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Cerrar [Esc]',
                        ),
                      ],
                    ),
                  ),

                  // Formulario
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selector de Medicamento
                          const Text(
                            'Medicamento a Ingresar *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                hint: const Text('Seleccionar producto del catálogo maestro...'),
                                value: _selectedPresentacionId,
                                items: products.expand((p) {
                                  return p.presentaciones.map((pres) {
                                    return DropdownMenuItem<int>(
                                      value: pres.id,
                                      child: Text(
                                        '${p.nombreComercial} - ${pres.nombreDescriptivo}',
                                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                      ),
                                    );
                                  });
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedPresentacionId = val;
                                    final found = products.firstWhere(
                                      (p) => p.presentaciones.any((pres) => pres.id == val),
                                    );
                                    _selectedProductName = found.nombreComercial;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: _lotCodeCtrl,
                                  label: 'Número de Lote *',
                                  hintText: 'Ej: LOT-2026-X01',
                                  validator: (v) => v == null || v.trim().isEmpty ? 'El lote es obligatorio' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Fecha de Caducidad *',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: _pickExpirationDate,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 44,
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppFormatters.date(_expirationDate),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _quantityCtrl,
                                  label: 'Cantidad a Ingresar *',
                                  hintText: '10',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) {
                                    final num = double.tryParse(v ?? '');
                                    if (num == null || num <= 0) return 'Cantidad inválida';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _costPriceCtrl,
                                  label: 'Costo Unitario Compra (\$)',
                                  hintText: '0.00',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _locationCtrl,
                                  label: 'Ubicación Física',
                                  hintText: 'Ej: Estante A-2, Nevera 1',
                                  prefixIcon: Icons.location_on_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _docRefCtrl,
                                  label: 'Doc. Referencia / Factura',
                                  hintText: 'Ej: Factura Proveedor #1052',
                                  prefixIcon: Icons.receipt_long,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botones inferiores
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppSecondaryButton(
                          text: 'Cancelar',
                          shortcutLabel: 'Esc',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        AppPrimaryButton(
                          text: 'Registrar Ingreso',
                          shortcutLabel: 'Enter',
                          icon: Icons.check_circle_outline,
                          onPressed: _onSave,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
