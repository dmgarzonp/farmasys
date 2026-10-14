import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../domain/entities/sale.dart';
import '../../domain/services/ticket_printer_service.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';

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
    final settings = ref.watch(settingsProvider);
    final colors = context.colors;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 600, // Un poco más ancho para mostrar bien el PDF y los controles
        height: 700,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
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
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.receipt_long, color: colors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vista Previa del Ticket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Comprobante interno de venta',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: colors.textMuted),
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
                    pharmacyName: settings.pharmacyName,
                  ),
                  initialPageFormat: PdfPageFormat.roll80,
                  allowPrinting: true,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  pdfFileName: 'Ticket_${sale.id}.pdf',
                  loadingWidget: Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                  // Deshabilitamos el scrollView interno para que se comporte mejor en el modal
                  scrollViewDecoration: BoxDecoration(color: colors.background),
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
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: colors.border)),
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
