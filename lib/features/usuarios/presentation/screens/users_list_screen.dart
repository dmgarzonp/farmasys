import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart' hide UserRole;
import '../../../../core/database/tables/usuarios_table.dart';
import '../../../../shared/components/components.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../controllers/users_controller.dart';
import '../widgets/user_form_dialog.dart';

enum UserFilter { activos, inactivos, todos }

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  UserFilter _currentFilter = UserFilter.activos;

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title and new user button
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                const Text(
                  'Personal y Usuarios',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Activos'),
                      selected: _currentFilter == UserFilter.activos,
                      onSelected: (val) => setState(() => _currentFilter = UserFilter.activos),
                      selectedColor: AppColors.primarySurface,
                      labelStyle: TextStyle(color: _currentFilter == UserFilter.activos ? AppColors.primaryDark : AppColors.textSecondary),
                      side: BorderSide(color: _currentFilter == UserFilter.activos ? AppColors.primary : AppColors.border),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Inactivos'),
                      selected: _currentFilter == UserFilter.inactivos,
                      onSelected: (val) => setState(() => _currentFilter = UserFilter.inactivos),
                      selectedColor: AppColors.lotExpired,
                      labelStyle: TextStyle(color: _currentFilter == UserFilter.inactivos ? AppColors.lotExpiredText : AppColors.textSecondary),
                      side: BorderSide(color: _currentFilter == UserFilter.inactivos ? AppColors.danger : AppColors.border),
                    ),
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _currentFilter == UserFilter.todos,
                      onSelected: (val) => setState(() => _currentFilter = UserFilter.todos),
                      selectedColor: AppColors.sidebarHoverBg,
                      labelStyle: TextStyle(color: _currentFilter == UserFilter.todos ? AppColors.textPrimary : AppColors.textSecondary),
                      side: BorderSide(color: _currentFilter == UserFilter.todos ? AppColors.textPrimary : AppColors.border),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openUserForm(context, ref, null),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Nuevo Usuario'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Data Table
            Expanded(
              child: XelaCard(
                padding: const EdgeInsets.all(0),
                child: usersState.when(
                  data: (users) => _buildDataTable(context, ref, users),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text('Error al cargar usuarios: $err', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, List<User> users) {
    final filteredUsers = users.where((u) {
      if (_currentFilter == UserFilter.activos) return u.isActive;
      if (_currentFilter == UserFilter.inactivos) return !u.isActive;
      return true;
    }).toList();

    if (filteredUsers.isEmpty) {
      return const Center(child: Text('No hay usuarios que coincidan con el filtro.', style: TextStyle(color: AppColors.textMuted)));
    }

    return AppDataTable<User>(
      columns: [
        AppTableColumn(label: 'ID', builder: (user) => Text(user.id.toString())),
        AppTableColumn(label: 'Usuario', builder: (user) => Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold))),
        AppTableColumn(label: 'Nombre Completo', builder: (user) => Text(user.fullName ?? '-')),
        AppTableColumn(label: 'Rol', builder: (user) => _buildRoleBadge(user.role)),
        AppTableColumn(label: 'Estado', builder: (user) => _buildStatusBadge(user.isActive)),
        AppTableColumn(label: 'Acciones', builder: (user) => _buildActions(context, ref, user)),
      ],
      data: filteredUsers,
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    String text;
    XelaBadgeVariant variant;

    switch (role) {
      case UserRole.administrador:
        text = 'Administrador';
        variant = XelaBadgeVariant.purple;
        break;
      case UserRole.farmaceutico:
        text = 'Farmacéutico';
        variant = XelaBadgeVariant.info;
        break;
      case UserRole.cajero:
        text = 'Cajero';
        variant = XelaBadgeVariant.warning;
        break;
    }

    return XelaBadge(text: text, variant: variant);
  }

  Widget _buildStatusBadge(bool isActive) {
    return XelaBadge(
      text: isActive ? 'Activo' : 'Inactivo',
      variant: isActive ? XelaBadgeVariant.success : XelaBadgeVariant.danger,
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 20),
          tooltip: 'Editar',
          onPressed: () => _openUserForm(context, ref, user),
        ),
        IconButton(
          icon: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 20),
          tooltip: 'Restablecer Contraseña',
          onPressed: () => _resetUserPassword(context, ref, user),
        ),
        IconButton(
          icon: Icon(
            user.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
            color: user.isActive ? AppColors.error : AppColors.success,
            size: 20,
          ),
          tooltip: user.isActive ? 'Desactivar' : 'Activar',
          onPressed: () => _toggleUserStatus(context, ref, user),
        ),
      ],
    );
  }

  Future<void> _openUserForm(BuildContext context, WidgetRef ref, User? user) async {
    final result = await UserFormDialog.show(context, user: user);

    if (result != null) {
      final notifier = ref.read(usersControllerProvider.notifier);
      try {
        if (user == null) {
          // Create
          await notifier.createUser(
            username: result['username'],
            password: result['password'],
            role: result['role'],
            fullName: result['fullName'],
            documento: result['documento'],
            telefonoFijo: result['telefonoFijo'],
            telefonoMovil: result['telefonoMovil'],
            correoPersonal: result['correoPersonal'],
            hireDate: result['hireDate'],
          );
          if (context.mounted) {
            AppSnackBars.showSuccess(context, message: 'Usuario creado exitosamente');
          }
        } else {
          // Update
          await notifier.updateUser(
            id: user.id,
            username: result['username'],
            role: result['role'],
            isActive: result['isActive'],
            password: result['password']?.isNotEmpty == true ? result['password'] : null,
            fullName: result['fullName'],
            documento: result['documento'],
            telefonoFijo: result['telefonoFijo'],
            telefonoMovil: result['telefonoMovil'],
            correoPersonal: result['correoPersonal'],
            hireDate: result['hireDate'],
          );
          if (context.mounted) {
            AppSnackBars.showSuccess(context, message: 'Usuario actualizado exitosamente');
          }
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBars.showError(context, message: 'Error: ${e.toString().replaceAll('Exception: ', '')}');
        }
      }
    }
  }

  Future<void> _toggleUserStatus(BuildContext context, WidgetRef ref, User user) async {
    final action = user.isActive ? 'desactivar' : 'activar';
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Confirmar Acción',
      message: '¿Estás seguro de que deseas $action al usuario ${user.username}?',
      confirmText: action.toUpperCase(),
      isDestructive: user.isActive,
    );

    if (confirmed) {
      try {
        await ref.read(usersControllerProvider.notifier).toggleUserStatus(user);
        if (context.mounted) {
          AppSnackBars.showSuccess(context, message: 'Estado del usuario actualizado');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBars.showError(context, message: 'Error: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _resetUserPassword(BuildContext context, WidgetRef ref, User user) async {
    final passwordController = TextEditingController(text: '${user.username}123');
    bool obscureTemp = true;
    bool forceChange = true;
    final formKey = GlobalKey<FormState>();

    final tempPassword = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Restablecer Contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vas a restablecer la contraseña de ${user.username}.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa la nueva contraseña para la cuenta.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscureTemp,
                  decoration: InputDecoration(
                    labelText: 'Contraseña Temporal',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(obscureTemp ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setStateDialog(() => obscureTemp = !obscureTemp),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 4 ? 'Mínimo 4 caracteres' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Exigir cambio de contraseña al ingresar', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Si está activo, se bloqueará la cuenta hasta que el trabajador asigne su propia clave.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  value: forceChange,
                  onChanged: (val) => setStateDialog(() => forceChange = val),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop(passwordController.text);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('RESTABLECER'),
            ),
          ],
        ),
      ),
    );

    if (tempPassword != null && tempPassword.isNotEmpty) {
      try {
        await ref.read(usersControllerProvider.notifier).resetPassword(user, tempPassword, forceChange: forceChange);
        if (context.mounted) {
          AppSnackBars.showSuccess(context, message: 'Contraseña actualizada correctamente');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBars.showError(context, message: 'Error: \${e.toString()}');
        }
      }
    }
  }
}
