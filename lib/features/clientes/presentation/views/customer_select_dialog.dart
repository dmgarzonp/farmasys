import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../data/repositories/drift_customer_repository.dart';
import '../../domain/entities/customer.dart';
import 'customer_form_dialog.dart';

/// Diálogo de búsqueda y selección de cliente en el Punto de Venta (SOLID: SRP)
class CustomerSelectDialog extends ConsumerStatefulWidget {
  const CustomerSelectDialog({super.key});

  static Future<Customer?> show(BuildContext context) {
    return showDialog<Customer>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const CustomerSelectDialog(),
    );
  }

  @override
  ConsumerState<CustomerSelectDialog> createState() => _CustomerSelectDialogState();
}

class _CustomerSelectDialogState extends ConsumerState<CustomerSelectDialog> {
  late TextEditingController _searchCtrl;
  final FocusNode _searchFocusNode = FocusNode();
  List<Customer> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _performSearch('');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final repo = ref.read(customerRepositoryProvider);
    final results = await repo.searchCustomers(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  void _onSelectConsumidorFinal() async {
    final repo = ref.read(customerRepositoryProvider);
    final cf = await repo.getConsumidorFinal();
    if (mounted) Navigator.of(context).pop(cf);
  }

  void _onNewCustomer() async {
    final created = await CustomerFormDialog.show(context);
    if (created != null && mounted) {
      final repo = ref.read(customerRepositoryProvider);
      final id = await repo.saveCustomer(created);
      final savedCustomer = created.copyWith(id: id);
      if (mounted) Navigator.of(context).pop(savedCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(null),
        const SingleActivator(LogicalKeyboardKey.f1): _onSelectConsumidorFinal,
        const SingleActivator(LogicalKeyboardKey.f2): _onNewCustomer,
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 16,
        backgroundColor: AppColors.cardBackground,
        child: Container(
          width: 580,
          height: 520,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people_outline, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Seleccionar Cliente',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppSecondaryButton(
                        text: 'Consumidor Final',
                        shortcutLabel: 'F1',
                        icon: Icons.flash_on,
                        onPressed: _onSelectConsumidorFinal,
                      ),
                      const SizedBox(width: 8),
                      AppPrimaryButton(
                        text: 'Nuevo',
                        shortcutLabel: 'F2',
                        icon: Icons.person_add,
                        onPressed: _onNewCustomer,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buscador
              AppTextField(
                hintText: 'Buscar por cédula, RUC o nombre...',
                controller: _searchCtrl,
                focusNode: _searchFocusNode,
                prefixIcon: Icons.search,
                onChanged: _performSearch,
              ),
              const SizedBox(height: 12),

              // Lista de Resultados
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_search_outlined, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                const Text('No se encontraron clientes', style: TextStyle(color: AppColors.textSecondary)),
                                const SizedBox(height: 12),
                                AppSecondaryButton(
                                  text: 'Registrar como Nuevo Cliente [F2]',
                                  onPressed: _onNewCustomer,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, index) {
                              final c = _results[index];
                              return ListTile(
                                dense: true,
                                hoverColor: AppColors.primary.withValues(alpha: 0.05),
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: c.isConsumidorFinal
                                      ? AppColors.textMuted.withValues(alpha: 0.2)
                                      : AppColors.primary.withValues(alpha: 0.1),
                                  child: Icon(
                                    c.isConsumidorFinal ? Icons.public : Icons.person,
                                    size: 16,
                                    color: c.isConsumidorFinal ? AppColors.textSecondary : AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  c.nombreCompleto,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                subtitle: Text(
                                  '${c.documento} • ${c.direccion ?? 'Sin dirección'}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                                onTap: () => Navigator.of(context).pop(c),
                              );
                            },
                          ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: AppSecondaryButton(
                  text: 'Cerrar',
                  shortcutLabel: 'Esc',
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
