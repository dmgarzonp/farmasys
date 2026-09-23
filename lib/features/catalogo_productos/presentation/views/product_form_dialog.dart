import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';

/// Diálogo modal ergonómico de escritorio para crear o editar un medicamento (SOLID: SRP)
class ProductFormDialog extends StatefulWidget {
  final Product? initialProduct;

  const ProductFormDialog({super.key, this.initialProduct});

  static Future<Product?> show(BuildContext context, {Product? product}) {
    return showDialog<Product>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProductFormDialog(initialProduct: product),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _barcodeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _activePrincipleCtrl;
  late TextEditingController _concentrationCtrl;

  // Datos de la presentación base
  late TextEditingController _presDescCtrl;
  late TextEditingController _unitsPerBoxCtrl;
  late TextEditingController _costPriceCtrl;
  late TextEditingController _salePriceCtrl;
  late TextEditingController _fractionPriceCtrl;

  bool _requiereReceta = false;
  bool _esPsicotropico = false;
  bool _esAntibiotico = false;
  bool _tieneIva = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    final pres = p?.presentaciones.isNotEmpty == true ? p!.presentaciones.first : null;

    _barcodeCtrl = TextEditingController(text: p?.codigoBarras ?? '');
    _nameCtrl = TextEditingController(text: p?.nombreComercial ?? '');
    _activePrincipleCtrl = TextEditingController(text: p?.principioActivo ?? '');
    _concentrationCtrl = TextEditingController(text: p?.concentracion ?? '');

    _presDescCtrl = TextEditingController(text: pres?.nombreDescriptivo ?? 'Caja Estándar');
    _unitsPerBoxCtrl = TextEditingController(text: pres?.unidadesPorCaja.toString() ?? '1');
    _costPriceCtrl = TextEditingController(text: pres?.precioCompraCaja.toStringAsFixed(2) ?? '0.00');
    _salePriceCtrl = TextEditingController(text: pres?.precioVentaCaja.toStringAsFixed(2) ?? '0.00');
    _fractionPriceCtrl = TextEditingController(text: pres?.precioVentaFraccion.toStringAsFixed(2) ?? '0.00');

    _requiereReceta = p?.requiereReceta ?? false;
    _esPsicotropico = p?.esPsicotropico ?? false;
    _esAntibiotico = p?.esAntibiotico ?? false;
    _tieneIva = pres?.tieneIva ?? false;
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _activePrincipleCtrl.dispose();
    _concentrationCtrl.dispose();
    _presDescCtrl.dispose();
    _unitsPerBoxCtrl.dispose();
    _costPriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _fractionPriceCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final presentation = ProductPresentation(
      id: widget.initialProduct?.presentaciones.isNotEmpty == true
          ? widget.initialProduct!.presentaciones.first.id
          : null,
      productoId: widget.initialProduct?.id,
      nombreDescriptivo: _presDescCtrl.text.trim(),
      unidadesPorCaja: int.tryParse(_unitsPerBoxCtrl.text) ?? 1,
      precioCompraCaja: double.tryParse(_costPriceCtrl.text) ?? 0.0,
      precioVentaCaja: double.tryParse(_salePriceCtrl.text) ?? 0.0,
      precioVentaFraccion: double.tryParse(_fractionPriceCtrl.text) ?? 0.0,
      tieneIva: _tieneIva,
      codigoBarras: _barcodeCtrl.text.trim().isNotEmpty ? _barcodeCtrl.text.trim() : null,
    );

    final product = Product(
      id: widget.initialProduct?.id,
      codigoBarras: _barcodeCtrl.text.trim().isNotEmpty ? _barcodeCtrl.text.trim() : null,
      nombreComercial: _nameCtrl.text.trim(),
      principioActivo: _activePrincipleCtrl.text.trim().isNotEmpty ? _activePrincipleCtrl.text.trim() : null,
      concentracion: _concentrationCtrl.text.trim().isNotEmpty ? _concentrationCtrl.text.trim() : null,
      requiereReceta: _requiereReceta,
      esPsicotropico: _esPsicotropico,
      esAntibiotico: _esAntibiotico,
      estado: widget.initialProduct?.estado ?? 'activo',
      presentaciones: [presentation],
    );

    Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialProduct != null;

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
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 780),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera del modal
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
                              child: const Icon(Icons.medication, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isEditing ? 'Editar Medicamento / Producto' : 'Nuevo Medicamento / Producto',
                              style: const TextStyle(
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

                  // Cuerpo del formulario con Scroll
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '1. Identificación y Farmacología',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: _nameCtrl,
                                  label: 'Nombre Comercial *',
                                  hintText: 'Ej: Paracetamol 500mg, Amoxicilina',
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'El nombre comercial es obligatorio' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _barcodeCtrl,
                                  label: 'Código de Barras',
                                  hintText: 'Pistolear escáner...',
                                  prefixIcon: Icons.qr_code_scanner,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: _activePrincipleCtrl,
                                  label: 'Principio Activo (DCI)',
                                  hintText: 'Ej: Ibuprofeno, Azitromicina',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _concentrationCtrl,
                                  label: 'Concentración',
                                  hintText: 'Ej: 500 mg, 50 mg/ml',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Regulaciones ARCSA (Ecuador)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.health_and_safety, color: AppColors.info, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Regulaciones y Trazabilidad ARCSA (Ecuador)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text('Requiere Receta', style: TextStyle(fontSize: 13)),
                                        value: _requiereReceta,
                                        onChanged: (v) => setState(() => _requiereReceta = v ?? false),
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text('Es Antibiótico', style: TextStyle(fontSize: 13)),
                                        value: _esAntibiotico,
                                        onChanged: (v) => setState(() => _esAntibiotico = v ?? false),
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text('Psicotrópico (Controlado)', style: TextStyle(fontSize: 13)),
                                        value: _esPsicotropico,
                                        onChanged: (v) => setState(() => _esPsicotropico = v ?? false),
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. Precios y Presentación Comercial
                          const Text(
                            '2. Presentación Comercial, Precios e Impuestos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: _presDescCtrl,
                                  label: 'Descripción de Presentación *',
                                  hintText: 'Ej: Caja x 30 tabletas',
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'Ingrese la descripción' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _unitsPerBoxCtrl,
                                  label: 'Unidades por Caja',
                                  hintText: '1',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _costPriceCtrl,
                                  label: 'Costo de Compra (Caja)',
                                  hintText: '0.00',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _salePriceCtrl,
                                  label: 'PVP Venta (Caja) *',
                                  hintText: '0.00',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'Ingrese el precio' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _fractionPriceCtrl,
                                  label: 'PVP Fracción / Suelto',
                                  hintText: '0.00',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _tieneIva ? AppColors.info.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _tieneIva ? AppColors.info.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _tieneIva ? Icons.percent : Icons.health_and_safety,
                                  size: 20,
                                  color: _tieneIva ? AppColors.info : AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final ivaVigente = ref.watch(settingsProvider).ivaVigente;
                                      return Text(
                                        _tieneIva
                                            ? 'Tarifa IVA ${(ivaVigente * 100).toInt()}% (Aplica a cosméticos, insumos y suplementos)'
                                            : 'Tarifa IVA 0% (Medicamentos de uso humano según Ley Tributaria Ecuador)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _tieneIva ? AppColors.info : AppColors.success,
                                        ),
                                      );
                                    }
                                  ),
                                ),
                                Switch(
                                  value: _tieneIva,
                                  activeThumbColor: AppColors.info,
                                  onChanged: (v) => setState(() => _tieneIva = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Barra de botones inferior
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
                          text: isEditing ? 'Guardar Cambios' : 'Registrar Producto',
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
