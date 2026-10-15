import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  print('Generando PDF del Manual de Licencias Temporales...');

  final pdf = pw.Document(
    title: 'Manual de Gestión de Licencias Temporales - FarmSys',
    author: 'FarmSys Ecuador',
  );

  final primaryColor = PdfColor.fromHex('#059669');
  final secondaryColor = PdfColor.fromHex('#0F172A');
  final slateMuted = PdfColor.fromHex('#64748B');
  final surfaceBg = PdfColor.fromHex('#F8FAFC');
  final borderSlate = PdfColor.fromHex('#E2E8F0');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 12),
        margin: const pw.EdgeInsets.only(bottom: 16),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: borderSlate, width: 1)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'FARMSYS ECUADOR - GESTIÓN COMERCIAL Y DE LICENCIAS',
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: slateMuted),
            ),
            pw.Text(
              'MANUAL DE LICENCIAS TEMPORALES (TRIAL 30 DÍAS)',
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: primaryColor),
            ),
          ],
        ),
      ),
      footer: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 10),
        margin: const pw.EdgeInsets.only(top: 16),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: borderSlate, width: 1)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Uso Interno y Comercial - FarmSys Ecuador', style: pw.TextStyle(fontSize: 8, color: slateMuted)),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: slateMuted)),
          ],
        ),
      ),
      build: (context) => [
        // Encabezado
        pw.Container(
          padding: const pw.EdgeInsets.all(18),
          decoration: pw.BoxDecoration(
            color: surfaceBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            border: pw.Border.all(color: borderSlate),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('FarmSys Ecuador', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text('GUÍA OPERATIVA & COMERCIAL', style: pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Text('Manual de Gestión de Licencias Temporales y Demos de 30 Días', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
              pw.SizedBox(height: 4),
              pw.Text('Protocolo de emisión de pruebas piloto, ciclo de vida, soporte y conversión de prospectos a clientes de pago.', style: pw.TextStyle(fontSize: 9, color: slateMuted)),
            ],
          ),
        ),
        pw.SizedBox(height: 18),

        // Sección 1
        _buildSectionHeader('1. Estrategia Comercial de las Licencias de Prueba', primaryColor),
        _buildParagraph('En el sector farmacéutico, la barrera principal para adquirir un software es la incertidumbre técnica y operativa. La licencia temporal de 30 días aplica la metodología Product-Led Growth (PLG): el farmacéutico instala el sistema, registra sus medicamentos y realiza ventas reales.'),
        pw.SizedBox(height: 6),
        _buildBulletPoint('Acceso 100% Funcional: Permite operar la facturación electrónica SRI, control de lotes y arqueo de caja sin limitaciones artificiales.'),
        _buildBulletPoint('Garantía de Retención de Datos: Nada se borra al expirar el trial. Todo el inventario cargado queda intacto en SQLite local.'),
        _buildBulletPoint('Conversión en 1 Segundo: Al contratar la anualidad, el cliente solo pega el nuevo token sin reinstalar ni volver a cargar datos.'),
        pw.SizedBox(height: 14),

        // Sección 2
        _buildSectionHeader('2. Ciclo de Vida de una Licencia Temporal', primaryColor),
        _buildStatusRow('Día 1 al 30', '🟢 TRIAL ACTIVO', 'Acceso pleno a ventas, SRI e inventario. El sistema muestra los días restantes en Configuración.', PdfColors.green700),
        _buildStatusRow('Día 31 al 45', '🟡 PERIODO DE GRACIA', '15 días adicionales de tolerancia. Sigue facturando con normalidad con alerta preventiva para renovar.', PdfColors.amber800),
        _buildStatusRow('Día 46 en adelante', '🔴 MODO SOLO CONSULTA', 'Las ventas se pausan para proteger la contabilidad. El catálogo, kardex y facturas históricas se preservan.', PdfColors.red700),
        pw.SizedBox(height: 14),

        // Sección 3
        _buildSectionHeader('3. Comandos de Emisión para el Proveedor', primaryColor),
        _buildSubHeader('A. Demo Estándar de 30 Días (Machine ID específico):'),
        _buildCodeBlock('dart run tool/generate_license.dart --trial --ruc 1792345678001 --name "Farmacia San Carlos" --machine "FARM-MCH-XXXX..."'),
        pw.SizedBox(height: 6),
        _buildSubHeader('B. Demo Universal / Multicaja (Uso de comodín *):'),
        _buildCodeBlock('dart run tool/generate_license.dart --trial --ruc 1792345678001 --name "Farmacia San Carlos" --machine "*"'),
        pw.SizedBox(height: 6),
        _buildSubHeader('C. Extensión Personalizada (ej. 15 días adicionales):'),
        _buildCodeBlock('dart run tool/generate_license.dart --ruc 1792345678001 --name "Farmacia San Carlos" --machine "FARM-MCH-XXXX..." --days 15 --plan trial'),
        pw.SizedBox(height: 14),

        // Sección 4
        _buildSectionHeader('4. Protocolo Semanal de Acompañamiento y Cierre', primaryColor),
        _buildStepItem('Semana 1 (Día 1-7): Onboarding', 'Instalar FarmSys, activar el token de 30 días, cargar los primeros 50 medicamentos y probar ticket térmico.'),
        _buildStepItem('Semana 2 (Día 8-14): Operación de Turnos', 'Capacitación en apertura y cierre de caja, registro de ventas rápidas con fracciones y descuentos.'),
        _buildStepItem('Semana 3 (Día 15-21): Facturación SRI', 'Carga de la firma electrónica .p12 y prueba de emisión electrónica autorizada por el SRI.'),
        _buildStepItem('Semana 4 (Día 22-30): Cierre Comercial', 'Aviso de fin de prueba, envío de propuesta de suscripción anual y entrega de la clave definitiva.'),
        pw.SizedBox(height: 14),

        // Sección 5
        _buildSectionHeader('5. Mecanismo de Seguridad y Clock Rollback Protection', primaryColor),
        _buildParagraph('Para evitar que un cliente altere la fecha de su sistema operativo para evadir el tiempo de expiración, FarmSys compara la hora local con la última marca de agua en SQLite. Si detecta un atraso mayor a 2 horas, activa el estado tamperedClock y bloquea ventas hasta sincronizar la hora oficial.'),
      ],
    ),
  );

  final outputDir = Directory.current.path;
  final outputFile = File('$outputDir/FarmSys_Manual_Gestion_Licencias_Temporales.pdf');
  await outputFile.writeAsBytes(await pdf.save());

  print('¡PDF de Licencias Temporales generado exitosamente!');
  print('Ubicación: ${outputFile.path}');
}

pw.Widget _buildSectionHeader(String title, PdfColor color) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 6),
    padding: const pw.EdgeInsets.only(bottom: 3),
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: color, width: 1.2)),
    ),
    child: pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
  );
}

pw.Widget _buildSubHeader(String title) {
  return pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B')));
}

pw.Widget _buildParagraph(String text) {
  return pw.Text(text, style: pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5, color: PdfColor.fromHex('#334155')));
}

pw.Widget _buildBulletPoint(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3, left: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'))),
        pw.Expanded(child: pw.Text(text, style: pw.TextStyle(fontSize: 8.5, color: PdfColor.fromHex('#334155')))),
      ],
    ),
  );
}

pw.Widget _buildStatusRow(String time, String status, String desc, PdfColor statusColor) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 4),
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#F8FAFC'),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 90, child: pw.Text(time, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B')))),
        pw.SizedBox(width: 120, child: pw.Text(status, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: statusColor))),
        pw.Expanded(child: pw.Text(desc, style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#475569')))),
      ],
    ),
  );
}

pw.Widget _buildCodeBlock(String code) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.symmetric(vertical: 3),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#0F172A'),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Text(code, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.white, lineSpacing: 1.4)),
  );
}

pw.Widget _buildStepItem(String title, String desc) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 4),
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#F8FAFC'),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'))),
        pw.SizedBox(height: 1),
        pw.Text(desc, style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#475569'))),
      ],
    ),
  );
}

