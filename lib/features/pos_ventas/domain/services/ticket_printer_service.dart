import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/formatters.dart';
import '../entities/sale.dart';

final ticketPrinterServiceProvider = Provider<TicketPrinterService>((ref) {
  return TicketPrinterService();
});

/// Servicio para la generación e impresión de comprobantes de venta internos (sin validez tributaria)
class TicketPrinterService {
  Future<Uint8List> generateTicketPdf({
    required Sale sale,
    required String cashierName,
  }) async {
    final pdf = pw.Document();

    // Formato de rollo térmico de 80mm (aprox. 3.14 pulgadas de ancho, la altura se expande)
    final format = PdfPageFormat.roll80;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Cabecera
              pw.Text(
                AppConstants.appName,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text('Farmacia POS', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              
              pw.Text(
                'COMPROBANTE DE VENTA INTERNO',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),

              // Si tiene clave de acceso, mostramos información oficial del SRI
              if (sale.claveAcceso != null && sale.claveAcceso!.isNotEmpty) ...[
                pw.Text('FACTURA ELECTRÓNICA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('CLAVE DE ACCESO:', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(sale.claveAcceso!, style: const pw.TextStyle(fontSize: 8)),
                // Opcional: Podríamos generar un código de barras de la clave de acceso aquí con pw.BarcodeWidget
                pw.SizedBox(height: 4),
              ] else ...[
                // Aviso Legal Obligatorio (Ecuador) para tickets internos
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  child: pw.Text(
                    'DOCUMENTO SIN VALIDEZ TRIBUTARIA\nNO VÁLIDO COMO FACTURA',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
              pw.SizedBox(height: 10),

              // Datos de Venta
              _buildRow('Ticket #:', sale.id.toString()),
              _buildRow('Fecha:', DateFormat('dd/MM/yyyy HH:mm').format(sale.fechaVenta)),
              _buildRow('Cajero/a:', cashierName),
              _buildRow('Cliente:', sale.clienteNombre ?? 'Consumidor Final'),
              _buildRow('Cédula/RUC:', sale.clienteDocumento ?? '9999999999999'),
              _buildRow('Método:', sale.metodoPago.toUpperCase()),
              
              pw.Divider(thickness: 1, height: 16),

              // Tabla de Productos
              pw.Row(
                children: [
                  pw.Expanded(flex: 1, child: pw.Text('Cant', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 3, child: pw.Text('Descripción', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 1, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.Divider(thickness: 0.5, height: 8),

              ...sale.detalles.map((d) {
                // Combinar la cantidad, podemos agrupar por presentación si la vista original fue agrupada, 
                // pero los detalles están desglosados por lote. 
                // Para el ticket al cliente podemos mostrar el detalle exacto.
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 1, 
                        child: pw.Text(
                          d.cantidad.toStringAsFixed(d.cantidad.truncateToDouble() == d.cantidad ? 0 : 2),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Expanded(
                        flex: 3, 
                        child: pw.Text(
                          '${d.productoNombre} ${d.presentacionNombre}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1, 
                        child: pw.Text(
                          AppFormatters.currency(d.subtotal + d.ivaTotal),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(thickness: 1, height: 16),

              // Liquidación
              _buildTotalRow('Subtotal 0%:', sale.subtotal0),
              _buildTotalRow('Subtotal IVA:', sale.subtotal12),
              _buildTotalRow('Descuento:', sale.descuentoTotal),
              _buildTotalRow('IVA 15%:', sale.impuestoTotal),
              
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL A PAGAR:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(AppFormatters.currency(sale.total), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              
              pw.SizedBox(height: 16),
              pw.Text('¡Gracias por su compra!', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 4),
              pw.Text('Revise su mercadería, no se aceptan devoluciones.', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 12),
              pw.Text('Software FarmSys', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  Future<void> printTicket({
    required Sale sale,
    required String cashierName,
  }) async {
    final bytes = await generateTicketPdf(sale: sale, cashierName: cashierName);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Ticket_${sale.id}',
    );
  }

  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(AppFormatters.currency(amount), style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
