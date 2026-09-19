import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../domain/entities/customer.dart';

/// Modal para creación o edición rápida de cliente en el Punto de Venta (SOLID: SRP)
class CustomerFormDialog extends StatefulWidget {
  final Customer? customer;

  const CustomerFormDialog({super.key, this.customer});

  static Future<Customer?> show(BuildContext context, {Customer? customer}) {
    return showDialog<Customer>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomerFormDialog(customer: customer),
    );
  }

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _docCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;

  final FocusNode _docFocusNode = FocusNode();
  String _tipoDoc = '05'; // 05 = Cédula, 04 = RUC, 06 = Pasaporte

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _docCtrl = TextEditingController(text: c?.documento ?? '');
    _nameCtrl = TextEditingController(text: c?.nombreCompleto ?? '');
    _phoneCtrl = TextEditingController(text: c?.telefono ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _addressCtrl = TextEditingController(text: c?.direccion ?? '');
    _tipoDoc = c?.tipoDocumento ?? '05';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _docFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _docCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _docFocusNode.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: widget.customer?.id,
      documento: _docCtrl.text.trim(),
      tipoDocumento: _tipoDoc,
      nombreCompleto: _nameCtrl.text.trim().toUpperCase(),
      telefono: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim().toLowerCase() : null,
      direccion: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim().toUpperCase() : null,
    );

    Navigator.of(context).pop(customer);
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
          width: 520,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_add_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer == null ? 'Registrar Nuevo Cliente' : 'Editar Datos de Cliente',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const Text(
                            'Información para emisión de comprobante y facturación',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tipo y Documento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tipoDoc,
                        decoration: const InputDecoration(
                          labelText: 'Tipo Doc.',
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: '05', child: Text('Cédula')),
                          DropdownMenuItem(value: '04', child: Text('RUC')),
                          DropdownMenuItem(value: '06', child: Text('Pasaporte')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _tipoDoc = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Número de Identificación *',
                        controller: _docCtrl,
                        focusNode: _docFocusNode,
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Requerido';
                          if (val.trim().length < 5) return 'Mínimo 5 caracteres';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nombres
                AppTextField(
                  label: 'Nombres y Apellidos / Razón Social *',
                  controller: _nameCtrl,
                  prefixIcon: Icons.account_circle_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El nombre es obligatorio';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Dirección y Teléfono
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Dirección Domiciliaria',
                        controller: _addressCtrl,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Teléfono / Móvil',
                        controller: _phoneCtrl,
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Email
                AppTextField(
                  label: 'Correo Electrónico (Para envío de factura)',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
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
                      text: 'Guardar Cliente',
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
