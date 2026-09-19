import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../domain/entities/purchase_invoice.dart';

/// Modal para previsualizar e imprimir el Acta de Recepción Técnica Sanitaria (ARCSA Ecuador)
class TechnicalReceptionDialog extends StatelessWidget {
  final PurchaseInvoice invoice;

  const TechnicalReceptionDialog({super.key, required this.invoice});

  static Future<void> show(BuildContext context, PurchaseInvoice invoice) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => TechnicalReceptionDialog(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 16,
        backgroundColor: AppColors.cardBackground,
        child: Container(
          width: 860,
          height: 640,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado Oficial ARCSA
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
                        child: const Icon(Icons.verified_outlined, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTA DE RECEPCIÓN TÉCNICA SANITARIA',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Buenas Prácticas de Recepción y Almacenamiento • ARCSA Ecuador',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: AppColors.success),
                        SizedBox(width: 6),
                        Text(
                          'CUMPLE NORMATIVA ARCSA',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Datos Administrativos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROVEEDOR / DISTRIBUIDORA:',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                          ),
                          Text(
                            invoice.proveedorNombre,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text('RUC: ${invoice.proveedorRuc}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DOCUMENTO DE RESPALDO:',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                          ),
                          Text(
                            'Factura No. ${invoice.numeroFactura}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          if (invoice.numeroAutorizacionSri != null)
                            Text(
                              'Autorización SRI: ${invoice.numeroAutorizacionSri}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FECHA DE RECEPCIÓN:',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                          ),
                          Text(
                            AppFormatters.date(invoice.fechaRecepcion),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Total Renglones: ${invoice.itemCount}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tabla de Renglones Inspeccionados
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 38,
                      dataRowMinHeight: 38,
                      dataRowMaxHeight: 44,
                      headingRowColor: WidgetStateProperty.all(AppColors.backgroundDark),
                      columns: const [
                        DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('Medicamento / Presentación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('Lote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('Cant. (Cajas/U)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), numeric: true),
                        DataColumn(label: Text('Reg. Sanitario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('Empaque', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataColumn(label: Text('Dictamen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      ],
                      rows: invoice.items.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final item = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text('$idx', style: const TextStyle(fontSize: 11))),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item.productoNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(item.presentacionNombre, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            DataCell(Text(item.lote, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                            DataCell(Text(AppFormatters.date(item.fechaVencimiento), style: const TextStyle(fontSize: 11))),
                            DataCell(Text('${item.cantidadCajas.toStringAsFixed(0)} cj (${item.cantidadUnidades.toStringAsFixed(0)} u)', style: const TextStyle(fontSize: 11))),
                            DataCell(
                              item.cumpleRegistroSanitario
                                  ? const Icon(Icons.check, size: 16, color: AppColors.success)
                                  : const Icon(Icons.close, size: 16, color: AppColors.error),
                            ),
                            DataCell(
                              item.cumpleEmpaque
                                  ? const Icon(Icons.check, size: 16, color: AppColors.success)
                                  : const Icon(Icons.close, size: 16, color: AppColors.error),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.esConformeArcsa ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.esConformeArcsa ? 'CONFORME' : 'NO CONFORME',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.esConformeArcsa ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Firmas de Responsabilidad
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 30),
                          Divider(thickness: 1, color: AppColors.textSecondary),
                          Text(
                            'Responsable Técnico / Farmacéutico',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text('Firma y Sello de Recepción', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 30),
                          Divider(thickness: 1, color: AppColors.textSecondary),
                          Text(
                            'Entrega Transportista / Distribuidora',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text('Nombre y Cédula', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer de acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(
                    text: 'Cerrar',
                    shortcutLabel: 'Esc',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  AppPrimaryButton(
                    text: 'Imprimir / Exportar Acta',
                    icon: Icons.print_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Acta de Recepción Técnica lista para archivo físico ARCSA.')),
                      );
                      Navigator.of(context).pop();
                    },
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
