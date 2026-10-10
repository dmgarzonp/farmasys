import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/xela_card.dart';
import '../../domain/entities/sale.dart';
import '../../domain/services/ticket_printer_service.dart';

/// Modal para previsualizar el ticket térmico antes de imprimir.
/// Integra el widget [PdfPreview] de la librería printing.
class TicketPreviewDialog extends ConsumerWidget {
  final Sale sale;
  final String cashierName;

  const TicketPreviewDialog({
    super.key,
    required this.sale,
    required this.cashierName,
  });

  static Future<void> show(
    BuildContext context, {
    required Sale sale,
    required String cashierName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TicketPreviewDialog(sale: sale, cashierName: cashierName),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerService = ref.watch(ticketPrinterServiceProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 600, // Un poco más ancho para mostrar bien el PDF y los controles
        height: 700,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cabecera del modal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vista Previa del Ticket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Comprobante interno de venta',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    tooltip: 'Cerrar sin imprimir',
                  ),
                ],
              ),
            ),

            // Contenedor del PdfPreview
            Expanded(
              child: ClipRRect(
                child: PdfPreview(
                  // Construye los bytes del documento
                  build: (format) => printerService.generateTicketPdf(
                    sale: sale,
                    cashierName: cashierName,
                  ),
                  initialPageFormat: PdfPageFormat.roll80,
                  allowPrinting: true,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  pdfFileName: 'Ticket_${sale.id}.pdf',
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  // Deshabilitamos el scrollView interno para que se comporte mejor en el modal
                  scrollViewDecoration: const BoxDecoration(color: AppColors.background),
                  pdfPreviewPageDecoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botonera final (Opcional, ya que PdfPreview incluye botones arriba, 
            // pero ponemos uno para cerrar claramente y seguir trabajando).
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(
                    text: 'Cerrar y Continuar [Esc]',
                    onPressed: () => context.pop(),
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
