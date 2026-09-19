import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../domain/entities/supplier.dart';

/// Modal para creación o edición rápida de proveedor o distribuidora farmacéutica (SOLID: SRP)
class SupplierFormDialog extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormDialog({super.key, this.supplier});

  static Future<Supplier?> show(BuildContext context, {Supplier? supplier}) {
    return showDialog<Supplier>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SupplierFormDialog(supplier: supplier),
    );
  }

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rucCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _contactNameCtrl;
  late TextEditingController _contactPhoneCtrl;
  late TextEditingController _contactEmailCtrl;

  final FocusNode _rucFocusNode = FocusNode();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _rucCtrl = TextEditingController(text: s?.ruc ?? '');
    _nameCtrl = TextEditingController(text: s?.nombreEmpresa ?? '');
    _addressCtrl = TextEditingController(text: s?.direccion ?? '');
    _phoneCtrl = TextEditingController(text: s?.telefonoEmpresa ?? '');
    _emailCtrl = TextEditingController(text: s?.emailEmpresa ?? '');
    _contactNameCtrl = TextEditingController(text: s?.nombreContacto ?? '');
    _contactPhoneCtrl = TextEditingController(text: s?.telefonoContacto ?? '');
    _contactEmailCtrl = TextEditingController(text: s?.emailContacto ?? '');
    _isActive = s?.isActive ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rucFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _rucCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactEmailCtrl.dispose();
    _rucFocusNode.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final supplier = Supplier(
      id: widget.supplier?.id,
      ruc: _rucCtrl.text.trim(),
      nombreEmpresa: _nameCtrl.text.trim().toUpperCase(),
      direccion: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim().toUpperCase() : null,
      telefonoEmpresa: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      emailEmpresa: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim().toLowerCase() : null,
      nombreContacto: _contactNameCtrl.text.trim().isNotEmpty ? _contactNameCtrl.text.trim().toUpperCase() : null,
      telefonoContacto: _contactPhoneCtrl.text.trim().isNotEmpty ? _contactPhoneCtrl.text.trim() : null,
      emailContacto: _contactEmailCtrl.text.trim().isNotEmpty ? _contactEmailCtrl.text.trim().toLowerCase() : null,
      estado: _isActive ? 'activo' : 'inactivo',
      createdAt: widget.supplier?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(supplier);
  }

  @override
  Widget build(BuildContext context) {
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
                // Encabezado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.supplier == null
                                ? 'Registrar Proveedor / Distribuidor'
                                : 'Editar Datos de Proveedor',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const Text(
                            'Información de distribuidora para abastecimiento y facturación ARCSA',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // RUC y Estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'RUC de la Empresa (13 dígitos) *',
                        controller: _rucCtrl,
                        focusNode: _rucFocusNode,
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'El RUC es obligatorio';
                          if (val.trim().length != 13) return 'Debe tener exactamente 13 dígitos';
                          if (!RegExp(r'^\d+$').hasMatch(val.trim())) return 'Solo números';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isActive,
                              onChanged: (val) => setState(() => _isActive = val ?? true),
                              activeColor: AppColors.primary,
                            ),
                            const Text(
                              'Proveedor Activo',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Razón Social / Nombre Comercial
                AppTextField(
                  label: 'Razón Social / Nombre Comercial *',
                  controller: _nameCtrl,
                  prefixIcon: Icons.store_mall_directory_outlined,
                  hintText: 'Ej: DISTRIBUIDORA FARMACÉUTICA ECUATORIANA S.A.',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El nombre de empresa es obligatorio';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Dirección y Teléfono Empresa
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Dirección de la Distribuidora',
                        controller: _addressCtrl,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Teléfono Empresa',
                        controller: _phoneCtrl,
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Contacto Vendedor / Agente
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Nombre del Agente / Vendedor de Zona',
                        controller: _contactNameCtrl,
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Teléfono Celular Agente',
                        controller: _contactPhoneCtrl,
                        prefixIcon: Icons.phone_android_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Email Empresa / Facturación
                AppTextField(
                  label: 'Correo Electrónico de Facturación / Pedidos',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
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
                      text: 'Guardar Proveedor',
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
