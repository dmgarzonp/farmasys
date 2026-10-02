import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_text_field.dart';
import '../../../proveedores/data/repositories/drift_supplier_repository.dart';
import '../../../proveedores/domain/entities/supplier.dart';
import '../../domain/entities/batch_stock.dart';

class BatchReturnDialog extends ConsumerStatefulWidget {
  final BatchStock batch;

  const BatchReturnDialog({super.key, required this.batch});

  static Future<Map<String, dynamic>?> show(BuildContext context, BatchStock batch) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BatchReturnDialog(batch: batch),
    );
  }

  @override
  ConsumerState<BatchReturnDialog> createState() => _BatchReturnDialogState();
}

class _BatchReturnDialogState extends ConsumerState<BatchReturnDialog> {
  final _qtyCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  String _selectedReason = 'descarte_vencimiento'; // devolucion_proveedor, cambio_proveedor, descarte_vencimiento
  List<Supplier> _suppliers = [];
  Supplier? _selectedSupplier;
  bool _isLoadingSuppliers = true;
  String? _qtyError;

  @override
  void initState() {
    super.initState();
    _qtyCtrl.text = widget.batch.stockActual.toStringAsFixed(0);
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final repo = ref.read(supplierRepositoryProvider);
      final list = await repo.getSuppliers(activeOnly: true);
      if (mounted) {
        setState(() {
          _suppliers = list;
          _isLoadingSuppliers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingSuppliers = false);
      }
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _refCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final qty = double.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) {
      setState(() => _qtyError = 'Cantidad inválida');
      return;
    }
    if (qty > widget.batch.stockActual) {
      setState(() => _qtyError = 'No puede superar el stock actual (${widget.batch.stockActual})');
      return;
    }

    if ((_selectedReason == 'devolucion_proveedor' || _selectedReason == 'cambio_proveedor') &&
        _selectedSupplier == null) {
      setState(() => _qtyError = 'Debe seleccionar un proveedor');
      return;
    }

    Navigator.of(context).pop({
      'quantity': qty,
      'reasonType': _selectedReason,
      'supplierId': _selectedSupplier?.id,
      'referenceDocument': _refCtrl.text.trim().isNotEmpty ? _refCtrl.text.trim() : null,
      'observations': _obsCtrl.text.trim().isNotEmpty ? _obsCtrl.text.trim() : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSupplierFields = _selectedReason == 'devolucion_proveedor' || _selectedReason == 'cambio_proveedor';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.outbox_rounded, color: AppColors.danger),
          const SizedBox(width: 8),
          const Text('Salida de Inventario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Producto: ${widget.batch.productName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Lote: ${widget.batch.lote}  |  Vence: ${widget.batch.fechaVencimiento.toString().split(' ')[0]}'),
                    const SizedBox(height: 4),
                    Text('Stock Actual: ${widget.batch.stockActual}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              const Text('Motivo de Salida:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'descarte_vencimiento', child: Text('Descarte por Vencimiento / Daño')),
                  DropdownMenuItem(value: 'devolucion_proveedor', child: Text('Devolución a Proveedor (Reembolso/NC)')),
                  DropdownMenuItem(value: 'cambio_proveedor', child: Text('Cambio Físico por Proveedor')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedReason = val;
                      if (!showSupplierFields) {
                        _selectedSupplier = null;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _qtyCtrl,
                label: 'Cantidad a Retirar *',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                errorText: _qtyError,
                onChanged: (_) {
                  if (_qtyError != null) setState(() => _qtyError = null);
                },
              ),
              const SizedBox(height: 16),

              if (showSupplierFields) ...[
                const Text('Proveedor:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                _isLoadingSuppliers
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<Supplier>(
                        value: _selectedSupplier,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Seleccione un proveedor',
                        ),
                        items: _suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.nombreEmpresa))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSupplier = val;
                            if (_qtyError != null) _qtyError = null;
                          });
                        },
                      ),
                const SizedBox(height: 16),
              ],

              AppTextField(
                controller: _refCtrl,
                label: 'Documento Referencia',
                hintText: 'Ej: Nota Crédito #123, Guía Remisión...',
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _obsCtrl,
                label: 'Observaciones',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppSecondaryButton(
          text: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppPrimaryButton(
          text: 'Confirmar Salida',
          icon: Icons.check_circle_outline,
          onPressed: _submit,
        ),
      ],
    );
  }
}
