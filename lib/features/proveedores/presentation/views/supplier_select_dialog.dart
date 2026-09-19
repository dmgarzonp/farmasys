import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../data/repositories/drift_supplier_repository.dart';
import '../../domain/entities/supplier.dart';
import 'supplier_form_dialog.dart';

/// Diálogo de búsqueda y selección rápida de proveedor o distribuidora (SOLID: SRP)
class SupplierSelectDialog extends ConsumerStatefulWidget {
  const SupplierSelectDialog({super.key});

  static Future<Supplier?> show(BuildContext context) {
    return showDialog<Supplier>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const SupplierSelectDialog(),
    );
  }

  @override
  ConsumerState<SupplierSelectDialog> createState() => _SupplierSelectDialogState();
}

class _SupplierSelectDialogState extends ConsumerState<SupplierSelectDialog> {
  late TextEditingController _searchCtrl;
  final FocusNode _searchFocusNode = FocusNode();
  List<Supplier> _results = [];
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
    final repo = ref.read(supplierRepositoryProvider);
    final results = await repo.searchSuppliers(query);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  void _onNewSupplier() async {
    final created = await SupplierFormDialog.show(context);
    if (created != null && mounted) {
      final repo = ref.read(supplierRepositoryProvider);
      final id = await repo.saveSupplier(created);
      final savedSupplier = created.copyWith(id: id);
      if (mounted) Navigator.of(context).pop(savedSupplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(null),
        const SingleActivator(LogicalKeyboardKey.f2): _onNewSupplier,
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 16,
        backgroundColor: AppColors.cardBackground,
        child: Container(
          width: 620,
          height: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                        child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar Proveedor / Distribuidora',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Buscar por RUC, nombre de empresa o contacto comercial',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppPrimaryButton(
                    text: 'Nuevo Proveedor',
                    shortcutLabel: 'F2',
                    icon: Icons.add,
                    onPressed: _onNewSupplier,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buscador en tiempo real
              AppTextField(
                controller: _searchCtrl,
                focusNode: _searchFocusNode,
                hintText: 'Buscar distribuidora por RUC o Razón Social...',
                prefixIcon: Icons.search,
                onChanged: _performSearch,
              ),
              const SizedBox(height: 12),

              // Lista de resultados
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.domain_disabled, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                                const SizedBox(height: 8),
                                const Text(
                                  'No se encontraron proveedores registrados',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                AppSecondaryButton(
                                  text: 'Registrar Nuevo',
                                  shortcutLabel: 'F2',
                                  icon: Icons.add,
                                  onPressed: _onNewSupplier,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                            itemBuilder: (context, index) {
                              final supplier = _results[index];
                              return InkWell(
                                onTap: () => Navigator.of(context).pop(supplier),
                                borderRadius: BorderRadius.circular(8),
                                hoverColor: AppColors.primary.withValues(alpha: 0.05),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundDark,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.business, size: 20, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              supplier.nombreEmpresa,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(
                                                  'RUC: ${supplier.ruc}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primaryDark,
                                                  ),
                                                ),
                                                if (supplier.nombreContacto != null) ...[
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Contacto: ${supplier.nombreContacto}',
                                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                  ),
                                                ],
                                                if (supplier.telefonoEmpresa != null || supplier.telefonoContacto != null) ...[
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Tel: ${supplier.telefonoEmpresa ?? supplier.telefonoContacto}',
                                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(
                    text: 'Cancelar',
                    shortcutLabel: 'Esc',
                    onPressed: () => Navigator.of(context).pop(null),
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
