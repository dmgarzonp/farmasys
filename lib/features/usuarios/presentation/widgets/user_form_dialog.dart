import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart' hide UserRole;
import '../../../../core/database/tables/usuarios_table.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../shared/components/components.dart';

class UserFormDialog extends StatefulWidget {
  final User? user; // Si es null, estamos creando. Si tiene valor, editando.

  const UserFormDialog({super.key, this.user});

  static Future<Map<String, dynamic>?> show(BuildContext context, {User? user}) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserFormDialog(user: user),
    );
  }

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;
  late TextEditingController _documentoController;
  late TextEditingController _telefonoFijoController;
  late TextEditingController _telefonoMovilController;
  late TextEditingController _correoPersonalController;
  late TextEditingController _confirmPasswordController;
  DateTime? _hireDate;
  UserRole _selectedRole = UserRole.cajero;
  bool _isActive = true;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController(text: widget.user?.fullName ?? '');
    _documentoController = TextEditingController(text: widget.user?.documento ?? '');
    _telefonoFijoController = TextEditingController(text: widget.user?.telefonoFijo ?? '');
    _telefonoMovilController = TextEditingController(text: widget.user?.telefonoMovil ?? '');
    _correoPersonalController = TextEditingController(text: widget.user?.correoPersonal ?? '');
    _confirmPasswordController = TextEditingController();
    _hireDate = widget.user?.hireDate;
    
    if (!_isEditing) {
      _fullNameController.addListener(_generateUsername);
    }
    
    if (_isEditing) {
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
    }
  }

  void _generateUsername() {
    if (_isEditing) return; // Don't auto-change if editing an existing user
    final text = _fullNameController.text.trim();
    if (text.isEmpty) {
      _usernameController.text = '';
      return;
    }
    
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    String username = '';
    
    if (words.length == 1) {
      username = words[0];
    } else if (words.length == 2) {
      username = '${words[0][0]}${words[1]}';
    } else if (words.length == 3) {
      username = '${words[0][0]}${words[1][0]}${words[2]}';
    } else if (words.length >= 4) {
      username = '${words[0][0]}${words[1][0]}${words[2]}${words[3][0]}';
    }
    
    // Remove accents and special characters (simple approach)
    username = username.replaceAll(RegExp(r'[áäâà]'), 'a')
                       .replaceAll(RegExp(r'[éëêè]'), 'e')
                       .replaceAll(RegExp(r'[íïîì]'), 'i')
                       .replaceAll(RegExp(r'[óöôò]'), 'o')
                       .replaceAll(RegExp(r'[úüûù]'), 'u')
                       .replaceAll(RegExp(r'[ñ]'), 'n')
                       .replaceAll(RegExp(r'[ÁÄÂÀ]'), 'A')
                       .replaceAll(RegExp(r'[ÉËÊÈ]'), 'E')
                       .replaceAll(RegExp(r'[ÍÏÎÌ]'), 'I')
                       .replaceAll(RegExp(r'[ÓÖÔÒ]'), 'O')
                       .replaceAll(RegExp(r'[ÚÜÛÙ]'), 'U')
                       .replaceAll(RegExp(r'[Ñ]'), 'N')
                       .toLowerCase();
                       
    _usernameController.text = username;
  }

  @override
  void dispose() {
    if (!_isEditing) {
      _fullNameController.removeListener(_generateUsername);
    }
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _documentoController.dispose();
    _telefonoFijoController.dispose();
    _telefonoMovilController.dispose();
    _correoPersonalController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'username': _usernameController.text.trim(),
        'password': _passwordController.text, // Puede estar vacío si edita y no la cambia
        'role': _selectedRole,
        'isActive': _isActive,
        'fullName': _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim().toUpperCase(),
        'documento': _documentoController.text.trim().isEmpty ? null : _documentoController.text.trim(),
        'telefonoFijo': _telefonoFijoController.text.trim().isEmpty ? null : _telefonoFijoController.text.trim(),
        'telefonoMovil': _telefonoMovilController.text.trim().isEmpty ? null : _telefonoMovilController.text.trim(),
        'correoPersonal': _correoPersonalController.text.trim().isEmpty ? null : _correoPersonalController.text.trim(),
        'hireDate': _hireDate,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.background,
      child: Container(
        width: 800, // Widened to accommodate 2 columns better
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Grid layout for fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Personal Info (PRIORITY)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Datos Personales', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Nombres y Apellidos Completos *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.badge_rounded),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Los nombres son obligatorios';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _documentoController,
                          decoration: InputDecoration(
                            labelText: 'Cédula / Documento',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.credit_card_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _telefonoFijoController,
                                decoration: InputDecoration(
                                  labelText: 'Teléfono Fijo',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: const Icon(Icons.phone_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _telefonoMovilController,
                                decoration: InputDecoration(
                                  labelText: 'Teléfono Móvil',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: const Icon(Icons.smartphone_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _correoPersonalController,
                          decoration: InputDecoration(
                            labelText: 'Correo Personal',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _hireDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() => _hireDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de Contratación',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
                            ),
                            child: Text(
                              _hireDate != null
                                  ? '${_hireDate!.day}/${_hireDate!.month}/${_hireDate!.year}'
                                  : 'Seleccionar Fecha',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Column: Account Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Datos de Cuenta', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          readOnly: !_isEditing, // Read only if creating (auto-generated)
                          decoration: InputDecoration(
                            labelText: 'Nombre de Usuario (Autogenerado)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            filled: !_isEditing,
                            fillColor: !_isEditing ? AppColors.backgroundDark : null,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Requerido';
                            if (value.length < 3) return 'Mín 3 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: _isEditing ? 'Nueva Contraseña (Opcional)' : 'Contraseña *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            helperText: 'Mín 8 caracteres, letras y números',
                            helperMaxLines: 2,
                          ),
                          validator: (value) {
                            if (!_isEditing && (value == null || value.isEmpty)) return 'Requerida';
                            if (value != null && value.isNotEmpty) {
                              final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d\S]{8,}$');
                              if (!regex.hasMatch(value)) {
                                return 'Debe tener mín 8 chars, 1 letra y 1 número';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.lock_clock_outlined),
                          ),
                          validator: (value) {
                            if (_passwordController.text.isNotEmpty) {
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Rol del Sistema *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.name[0].toUpperCase() + role.name.substring(1)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRole = val);
                          },
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Cuenta Activa', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Si se desactiva, no podrá iniciar sesión.'),
                            value: _isActive,
                            onChanged: (val) => setState(() => _isActive = val),
                            activeTrackColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),



              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(_isEditing ? 'Guardar Cambios' : 'Crear Usuario'),
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
