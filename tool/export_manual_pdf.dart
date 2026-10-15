import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generador de documento PDF oficial a partir del manual de activación de FarmSys
void main() async {
  print('Generando documento PDF oficial de FarmSys...');

  final pdf = pw.Document(
    title: 'Manual de Activación de Licencias y Facturación Electrónica SRI - FarmSys',
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
              'FARMSYS ECUADOR - SISTEMA DE GESTIÓN Y PUNTO DE VENTA',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: slateMuted,
              ),
            ),
            pw.Text(
              'MANUAL OPERATIVO Y TÉCNICO',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
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
            pw.Text(
              'Confidencial - Uso Comercial y Operativo',
              style: pw.TextStyle(fontSize: 8, color: slateMuted),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: slateMuted,
              ),
            ),
          ],
        ),
      ),
      build: (context) => [
        // Portada / Encabezado Principal
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: surfaceBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            border: pw.Border.all(color: borderSlate),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'FarmSys Ecuador',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Text(
                      'VERSIÓN 1.0 OFICIAL',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Manual de Activación de Licencias Comerciales y Enlace de Facturación Electrónica SRI',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Guía operativa y técnica paso a paso para el proveedor de software y el cliente farmacéutico.',
                style: pw.TextStyle(fontSize: 10, color: slateMuted),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Sección 1
        _buildSectionHeader('1. Introducción y Arquitectura de Licenciamiento', primaryColor),
        _buildParagraph(
          'FarmSys opera bajo una arquitectura Local-First (Offline-Capable) con base de datos local SQLite (Drift). Para proteger los derechos comerciales del software y asegurar que la farmacia opere sin interrupciones aun sin internet, el sistema de licenciamiento se basa en criptografía asimétrica HMAC-SHA256 y vinculación física por Hardware Fingerprint (Machine ID).',
        ),
        pw.SizedBox(height: 8),
        _buildCallout(
          'Principio de Independencia: El cliente no requiere conexión permanente a internet para registrar ventas o consultar su inventario. El token criptográfico valida localmente en la máquina del cliente la vigencia y la autenticidad de la firma.',
          primaryColor,
          surfaceBg,
          borderSlate,
        ),
        pw.SizedBox(height: 16),

        // Sección 2
        _buildSectionHeader('2. Rol del Proveedor: ¿Cómo Emitir Licencias?', primaryColor),
        _buildParagraph(
          'Como dueño y proveedor de FarmSys, tú posees la autoridad certificadora. No requieres plataformas de terceros ni pagar mensualidades para expedir licencias a tus clientes. Dispones de la herramienta oficial integrada: tool/generate_license.dart.',
        ),
        pw.SizedBox(height: 8),
        _buildSubHeader('Comando Rápido desde la Terminal:'),
        _buildCodeBlock(
          'dart run tool/generate_license.dart \\\n'
          '  --ruc 1792345678001 \\\n'
          '  --name "Farmacia San Carlos" \\\n'
          '  --machine "FARM-MCH-9B4F-8A2C-1E30" \\\n'
          '  --days 365 \\\n'
          '  --plan pro',
        ),
        pw.SizedBox(height: 8),
        _buildParagraph(
          'Tip Comercial para Demos de 30 días: Para emitir una licencia temporal de prueba, puedes utilizar el comando rápido con --trial (o --days 30). De esta forma el cliente disfruta de 30 días de evaluación completa sin costo inicial.',
        ),
        pw.SizedBox(height: 8),
        _buildParagraph(
          'Licencias Multicaja: Si la farmacia cuenta con varias computadoras (caja 1, caja 2, administración) y adquirió un plan multidispensario, coloca "*" en el parámetro --machine para emitir una licencia universal para ese RUC.',
        ),
        pw.SizedBox(height: 16),

        // Sección 3
        _buildSectionHeader('3. Rol del Cliente: Activación en FarmSys', primaryColor),
        _buildStepItem('Paso 1: Copiar el Machine ID', 'El farmacéutico ingresa a Configuración -> Facturación Electrónica SRI & Licencia y presiona el botón [Copiar ID] (ej. FARM-MCH-XXXX-XXXX-XXXX) y se lo envía al proveedor por WhatsApp o correo.'),
        _buildStepItem('Paso 2: Abrir el Modal de Activación', 'En la misma pantalla de Configuración, presiona el botón [Activar Licencia Comercial] o [Renovar / Cambiar].'),
        _buildStepItem('Paso 3: Pegar el Token Criptográfico', 'Pega el código firmado recibido y presiona [Activar Licencia]. El sistema valida la firma y desbloquea el sistema de inmediato con mensaje de éxito.'),
        pw.SizedBox(height: 16),

        // Sección 4
        _buildSectionHeader('4. Activación del Módulo de Facturación Electrónica SRI', primaryColor),
        _buildParagraph(
          'Al activar la licencia PRO o Trial, el sistema lanza de manera automática el Asistente de Configuración SRI (SriSetupWizardDialog), estructurado en 4 fases:',
        ),
        pw.SizedBox(height: 6),
        _buildBulletPoint('Fase 1: Datos del Emisor (RUC de 13 dígitos, Razón Social, Nombre Comercial, Dirección Matriz y Sucursal, Régimen RIMPE o General).'),
        _buildBulletPoint('Fase 2: Puntos de Emisión (Código de establecimiento 001, punto de emisión 001 y secuencial inicial de facturas).'),
        _buildBulletPoint('Fase 3: Ambiente SRI (Ambiente 1 para Pruebas / Certificación técnica, Ambiente 2 para Producción oficial con validez jurídica).'),
        _buildBulletPoint('Fase 4: Certificado de Firma Digital (.p12) (Selección del archivo .p12 o .pfx emitido por Security Data, Banco Central, Uanataca, etc., e ingreso seguro de la contraseña cifrada localmente).'),
        pw.SizedBox(height: 16),

        // Sección 5
        _buildSectionHeader('5. Estados de la Licencia, Periodo de Gracia y Modo Solo Consulta', primaryColor),
        _buildParagraph(
          'FarmSys implementa un ciclo de vida robusto para no perjudicar la operación del cliente:',
        ),
        pw.SizedBox(height: 8),
        _buildStatusCard('🟢 Licencia Activa (Vigente)', 'Todas las funciones habilitadas: ventas, inventario, reportes y emisión electrónica SRI.', PdfColors.green700),
        pw.SizedBox(height: 6),
        _buildStatusCard('🟡 Periodo de Gracia (15 días post-vencimiento)', 'Si la suscripción vence, la farmacia dispone de 15 días continuos de tolerancia donde puede seguir facturando con normalidad mientras formaliza su renovación.', PdfColors.amber800),
        pw.SizedBox(height: 6),
        _buildStatusCard('🔴 Modo Solo Consulta (Caducada)', 'Si transcurre el periodo de gracia sin renovar, los datos contables y facturas se preservan intactos, pero se inhabilita el botón de cobro en el POS hasta ingresar la nueva clave de renovación.', PdfColors.red700),
        pw.SizedBox(height: 6),
        _buildStatusCard('⚠️ Reloj Desincronizado (Clock Rollback)', 'Si se detecta que el reloj de la computadora retrocedió más de 2 horas para burlar la vigencia, el sistema bloquea ventas hasta sincronizar la hora oficial (GMT-5).', PdfColors.orange800),
        pw.SizedBox(height: 16),

        // Sección 6
        _buildSectionHeader('6. Procedimiento de Migración de Equipo', primaryColor),
        _buildParagraph(
          'Si la farmacia cambia de computadora o formatea el disco: basta con presionar [Desactivar Licencia] en la máquina anterior, instalar FarmSys en la nueva computadora, obtener el nuevo Machine ID y generar el nuevo token de reemplazo sin costo adicional.',
        ),
      ],
    ),
  );

  final outputDir = Directory.current.path;
  final outputFile = File('$outputDir/FarmSys_Manual_Licencias_y_Facturacion_SRI.pdf');
  await outputFile.writeAsBytes(await pdf.save());

  print('¡PDF generado exitosamente!');
  print('Ubicación: ${outputFile.path}');
}

pw.Widget _buildSectionHeader(String title, PdfColor color) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.only(bottom: 4),
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: color, width: 1.5)),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    ),
  );
}

pw.Widget _buildSubHeader(String title) {
  return pw.Text(
    title,
    style: pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#1E293B'),
    ),
  );
}

pw.Widget _buildParagraph(String text) {
  return pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 9.5,
      lineSpacing: 2,
      color: PdfColor.fromHex('#334155'),
    ),
  );
}

pw.Widget _buildBulletPoint(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4, left: 10),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'))),
        pw.Expanded(
          child: pw.Text(text, style: pw.TextStyle(fontSize: 9, lineSpacing: 1.5, color: PdfColor.fromHex('#334155'))),
        ),
      ],
    ),
  );
}

pw.Widget _buildStepItem(String title, String description) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#F8FAFC'),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'))),
        pw.SizedBox(height: 2),
        pw.Text(description, style: pw.TextStyle(fontSize: 8.5, color: PdfColor.fromHex('#475569'))),
      ],
    ),
  );
}

pw.Widget _buildCodeBlock(String code) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    margin: const pw.EdgeInsets.symmetric(vertical: 4),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#0F172A'),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
    ),
    child: pw.Text(
      code,
      style: pw.TextStyle(
        fontSize: 8,
        color: PdfColor.fromHex('#F8FAFC'),
        lineSpacing: 1.5,
      ),
    ),
  );
}

pw.Widget _buildCallout(String text, PdfColor color, PdfColor bg, PdfColor border) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: bg,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border.all(color: color, width: 0.8),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: color),
    ),
  );
}

pw.Widget _buildStatusCard(String title, String description, PdfColor titleColor) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#F8FAFC'),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: titleColor)),
        pw.SizedBox(height: 2),
        pw.Text(description, style: pw.TextStyle(fontSize: 8.5, color: PdfColor.fromHex('#475569'))),
      ],
    ),
  );
}
