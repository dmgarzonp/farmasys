import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../entities/catalog_import_row.dart';

/// Servicio de dominio para la importación y procesamiento masivo de productos e inventario.
class CatalogImportService {
  static const String csvHeaderTemplate =
      'CODIGO_BARRAS;NOMBRE_COMERCIAL;PRINCIPIO_ACTIVO;CONCENTRACION;PRESENTACION;UNIDADES_CAJA;COSTO_CAJA;PVP_CAJA;TIENE_IVA;LOTE;FECHA_VENCIMIENTO;STOCK_INICIAL;UBICACION;REQUIERE_RECETA;PSICOTROPICO;ANTIBIOTICO';

  static const List<String> sampleRows = [
    '78610001001;PARACETAMOL 500 MG;Paracetamol;500 mg;Caja x 100;100;2.50;5.00;NO;L-2026A;2027-12-31;50;Estante A;NO;NO;NO',
    '78610001002;AMOXICILINA 500 MG;Amoxicilina;500 mg;Caja x 50;50;4.20;8.50;NO;L-9988;2026-10-31;20;Estante B;SI;NO;SI',
    '78610001003;ALCOHOL ANTISEPTICO 70%;Alcohol Etílico;70%;Frasco 500 ml;1;1.10;2.00;SI;L-7744;2028-06-30;100;Bodega;NO;NO;NO',
    '78610001004;IBUPROFENO 600 MG;Ibuprofeno;600 mg;Caja x 30;30;2.10;4.80;NO;L-1234;2027-05-15;0;Estante C;NO;NO;NO',
  ];

  /// Genera el contenido de texto para la plantilla CSV oficial de FarmSys
  static String generateTemplateCsv() {
    final buffer = StringBuffer();
    buffer.writeln(csvHeaderTemplate);
    for (final row in sampleRows) {
      buffer.writeln(row);
    }
    return buffer.toString();
  }

  /// Guarda la plantilla CSV en disco con BOM UTF-8 para apertura directa en Microsoft Excel
  static Future<File> saveTemplateToFile(String filePath) async {
    final content = generateTemplateCsv();
    final file = File(filePath);
    // Incluimos BOM UTF-8 (\uFEFF) para que Excel detecte tildes y caracteres en español
    final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(content)];
    return file.writeAsBytes(bytes);
  }

  /// Detecta automáticamente el delimitador del archivo CSV (punto y coma, coma o tabulación)
  static String detectDelimiter(String headerLine) {
    int semicolons = 0;
    int commas = 0;
    int tabs = 0;

    for (int i = 0; i < headerLine.length; i++) {
      final char = headerLine[i];
      if (char == ';') semicolons++;
      if (char == ',') commas++;
      if (char == '\t') tabs++;
    }

    if (tabs > semicolons && tabs > commas) return '\t';
    if (semicolons >= commas) return ';';
    return ',';
  }

  /// Parsea y valida el contenido de un archivo CSV en una lista estructurada de [CatalogImportRow]
  static List<CatalogImportRow> parseAndValidateCsv(String rawContent) {
    if (rawContent.trim().isEmpty) return [];

    // Limpiar BOM si existe
    var content = rawContent;
    if (content.startsWith('\uFEFF')) {
      content = content.substring(1);
    }

    final lines = content.split(RegExp(r'\r\n|\r|\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [];

    final delimiter = detectDelimiter(lines.first);
    final csvCodec = Csv(
      fieldDelimiter: delimiter,
      autoDetect: false,
      skipEmptyLines: true,
      dynamicTyping: false,
    );

    final parsedRows = csvCodec.decode(content);
    if (parsedRows.isEmpty) return [];

    // Mapear posiciones de columnas por nombre de cabecera
    final headerRow = parsedRows.first.map((e) => e.toString().trim().toUpperCase()).toList();
    final colMap = <String, int>{};

    for (int i = 0; i < headerRow.length; i++) {
      final colName = headerRow[i].replaceAll(' ', '_');
      colMap[colName] = i;
    }

    int? getColIndex(List<String> aliases) {
      for (final alias in aliases) {
        if (colMap.containsKey(alias)) return colMap[alias];
      }
      return null;
    }

    final idxCodigo = getColIndex(['CODIGO_BARRAS', 'CODIGO', 'BARCODE', 'COD']);
    final idxNombre = getColIndex(['NOMBRE_COMERCIAL', 'NOMBRE', 'PRODUCTO', 'DESCRIPCION']);
    final idxPrincipio = getColIndex(['PRINCIPIO_ACTIVO', 'PRINCIPIO', 'GENERICO']);
    final idxConcentracion = getColIndex(['CONCENTRACION', 'DOSIS']);
    final idxPresentacion = getColIndex(['PRESENTACION', 'FORMATO', 'EMPAQUE']);
    final idxUnidades = getColIndex(['UNIDADES_CAJA', 'UNIDADES', 'FRACCION']);
    final idxCosto = getColIndex(['COSTO_CAJA', 'COSTO', 'PRECIO_COMPRA']);
    final idxPvp = getColIndex(['PVP_CAJA', 'PVP', 'PRECIO_VENTA', 'PRECIO']);
    final idxIva = getColIndex(['TIENE_IVA', 'IVA', 'APLICA_IVA']);
    final idxLote = getColIndex(['LOTE', 'NUMERO_LOTE', 'BATCH']);
    final idxVence = getColIndex(['FECHA_VENCIMIENTO', 'VENCIMIENTO', 'CADUCIDAD', 'VENCE', 'FECHA_CADUCIDAD']);
    final idxStock = getColIndex(['STOCK_INICIAL', 'STOCK', 'CANTIDAD', 'EXISTENCIAS']);
    final idxUbicacion = getColIndex(['UBICACION', 'ESTANTE', 'PERCHA', 'BODEGA']);
    final idxReceta = getColIndex(['REQUIERE_RECETA', 'RECETA', 'RECETA_MEDICA']);
    final idxPsicotropico = getColIndex(['PSICOTROPICO', 'ES_PSICOTROPICO', 'CONTROLADO']);
    final idxAntibiotico = getColIndex(['ANTIBIOTICO', 'ES_ANTIBIOTICO']);

    final result = <CatalogImportRow>[];

    for (int r = 1; r < parsedRows.length; r++) {
      final row = parsedRows[r];
      if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) {
        continue;
      }

      String? getVal(int? index) {
        if (index == null || index >= row.length) return null;
        final v = row[index].toString().trim();
        return v.isEmpty ? null : v;
      }

      final codigoBarras = getVal(idxCodigo);
      final nombreComercial = getVal(idxNombre) ?? '';
      final principioActivo = getVal(idxPrincipio);
      final concentracion = getVal(idxConcentracion);
      final presentacion = getVal(idxPresentacion) ?? 'Caja x 1';
      final unidadesPorCaja = _parseInt(getVal(idxUnidades), defaultValue: 1);
      final costoCaja = _parseDouble(getVal(idxCosto), defaultValue: 0.0);
      final precioVentaCaja = _parseDouble(getVal(idxPvp), defaultValue: 0.0);
      final precioVentaFraccion =
          unidadesPorCaja > 1 ? (precioVentaCaja / unidadesPorCaja) : precioVentaCaja;
      final tieneIva = _parseBool(getVal(idxIva), defaultValue: false);
      final lote = getVal(idxLote);
      final fechaVencimiento = _parseDate(getVal(idxVence));
      final stockInicial = _parseDouble(getVal(idxStock), defaultValue: 0.0);
      final ubicacion = getVal(idxUbicacion);
      final requiereReceta = _parseBool(getVal(idxReceta), defaultValue: false);
      final esPsicotropico = _parseBool(getVal(idxPsicotropico), defaultValue: false);
      final esAntibiotico = _parseBool(getVal(idxAntibiotico), defaultValue: false);

      // Validaciones de negocio
      final errors = <String>[];
      if (nombreComercial.isEmpty) {
        errors.add('El nombre comercial es obligatorio.');
      }
      if (precioVentaCaja <= 0.0) {
        errors.add('El precio de venta (PVP) debe ser mayor a 0.00.');
      }
      if (costoCaja < 0.0) {
        errors.add('El costo no puede ser negativo.');
      }
      if (unidadesPorCaja < 1) {
        errors.add('Las unidades por caja deben ser al menos 1.');
      }
      if (stockInicial < 0.0) {
        errors.add('El stock inicial no puede ser negativo.');
      }
      if (stockInicial > 0.0) {
        if (fechaVencimiento == null) {
          errors.add('Si ingresa stock inicial, debe indicar fecha de vencimiento (AAAA-MM-DD o DD/MM/AAAA).');
        } else if (fechaVencimiento.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          errors.add('La fecha de vencimiento ingresada ya caducó.');
        }
      }

      result.add(
        CatalogImportRow(
          rowNumber: r + 1, // 1-indexed para coincidir con el Excel del usuario
          codigoBarras: codigoBarras,
          nombreComercial: nombreComercial,
          principioActivo: principioActivo,
          concentracion: concentracion,
          presentacion: presentacion,
          unidadesPorCaja: unidadesPorCaja,
          costoCaja: costoCaja,
          precioVentaCaja: precioVentaCaja,
          precioVentaFraccion: precioVentaFraccion,
          tieneIva: tieneIva,
          lote: lote ?? (stockInicial > 0 ? 'INICIAL' : null),
          fechaVencimiento: fechaVencimiento,
          stockInicial: stockInicial,
          ubicacion: ubicacion,
          requiereReceta: requiereReceta,
          esPsicotropico: esPsicotropico,
          esAntibiotico: esAntibiotico,
          errors: errors,
        ),
      );
    }

    return result;
  }

  /// Ejecuta la transacción atómica de base de datos para insertar o actualizar el catálogo y lotes
  static Future<CatalogImportSummary> executeImport({
    required List<CatalogImportRow> rows,
    required AppDatabase db,
    bool skipInvalid = true,
  }) async {
    final startTime = DateTime.now();
    int productsCreated = 0;
    int productsUpdated = 0;
    int batchesCreated = 0;

    final targetRows = skipInvalid ? rows.where((r) => r.isValid).toList() : rows;

    await db.transaction(() async {
      for (final row in targetRows) {
        // 1. Determinar si el producto ya existe (por código de barras o por nombre exacto)
        int productId;
        ProductosTableData? existingProduct;

        if (row.codigoBarras != null && row.codigoBarras!.isNotEmpty) {
          existingProduct = await (db.select(db.productosTable)
                ..where((tbl) => tbl.codigoBarras.equals(row.codigoBarras!)))
              .getSingleOrNull();
        }

        existingProduct ??= await (db.select(db.productosTable)
              ..where((tbl) => tbl.nombreComercial.lower().equals(row.nombreComercial.toLowerCase())))
            .getSingleOrNull();

        if (existingProduct != null) {
          productId = existingProduct.id;
          // Actualizamos información regulatoria si vino especificada
          await (db.update(db.productosTable)..where((tbl) => tbl.id.equals(productId))).write(
            ProductosTableCompanion(
              principioActivo: Value(row.principioActivo ?? existingProduct.principioActivo),
              concentracion: Value(row.concentracion ?? existingProduct.concentracion),
              requiereReceta: Value(row.requiereReceta),
              esPsicotropico: Value(row.esPsicotropico),
              esAntibiotico: Value(row.esAntibiotico),
              updatedAt: Value(DateTime.now()),
            ),
          );
          productsUpdated++;
        } else {
          productId = await db.into(db.productosTable).insert(
                ProductosTableCompanion.insert(
                  nombreComercial: row.nombreComercial,
                  codigoBarras: Value(row.codigoBarras),
                  principioActivo: Value(row.principioActivo),
                  concentracion: Value(row.concentracion),
                  requiereReceta: Value(row.requiereReceta),
                  esPsicotropico: Value(row.esPsicotropico),
                  esAntibiotico: Value(row.esAntibiotico),
                  estado: const Value('activo'),
                  createdAt: Value(DateTime.now()),
                ),
              );
          productsCreated++;
        }

        // 2. Gestionar la Presentación comercial
        final existingPresentation = await (db.select(db.presentacionesTable)
              ..where((tbl) =>
                  tbl.productoId.equals(productId) &
                  tbl.nombreDescriptivo.lower().equals(row.presentacion.toLowerCase())))
            .getSingleOrNull();

        int presentationId;
        if (existingPresentation != null) {
          presentationId = existingPresentation.id;
          await (db.update(db.presentacionesTable)..where((tbl) => tbl.id.equals(presentationId))).write(
            PresentacionesTableCompanion(
              unidadesPorCaja: Value(row.unidadesPorCaja),
              precioCompraCaja: Value(row.costoCaja),
              precioVentaCaja: Value(row.precioVentaCaja),
              precioVentaFraccion: Value(row.precioVentaFraccion),
              tieneIva: Value(row.tieneIva),
              codigoBarras: Value(row.codigoBarras ?? existingPresentation.codigoBarras),
            ),
          );
        } else {
          presentationId = await db.into(db.presentacionesTable).insert(
                PresentacionesTableCompanion.insert(
                  productoId: productId,
                  nombreDescriptivo: row.presentacion,
                  unidadesPorCaja: Value(row.unidadesPorCaja),
                  precioCompraCaja: Value(row.costoCaja),
                  precioVentaCaja: Value(row.precioVentaCaja),
                  precioVentaFraccion: Value(row.precioVentaFraccion),
                  codigoBarras: Value(row.codigoBarras),
                  tieneIva: Value(row.tieneIva),
                  stockMinimo: const Value(5),
                ),
              );
        }

        // 3. Si se definió stock inicial mayor a 0, crear Lote y Asiento de Kardex
        if (row.hasStock && row.fechaVencimiento != null) {
          final batchName = (row.lote != null && row.lote!.isNotEmpty) ? row.lote! : 'INICIAL';

          final existingBatch = await (db.select(db.lotesTable)
                ..where((tbl) =>
                    tbl.presentacionId.equals(presentationId) &
                    tbl.lote.lower().equals(batchName.toLowerCase())))
              .getSingleOrNull();

          int batchId;
          if (existingBatch != null) {
            batchId = existingBatch.id;
            final newTotalStock = existingBatch.stockActual + row.stockInicial;
            await (db.update(db.lotesTable)..where((tbl) => tbl.id.equals(batchId))).write(
              LotesTableCompanion(
                stockActual: Value(newTotalStock),
                precioCompraCaja: Value(row.costoCaja),
                precioCompraUnitario: Value(row.unidadesPorCaja > 0 ? (row.costoCaja / row.unidadesPorCaja) : row.costoCaja),
                ubicacion: Value(row.ubicacion ?? existingBatch.ubicacion),
                fechaVencimiento: Value(row.fechaVencimiento!),
              ),
            );
          } else {
            batchId = await db.into(db.lotesTable).insert(
                  LotesTableCompanion.insert(
                    presentacionId: presentationId,
                    lote: batchName,
                    fechaVencimiento: row.fechaVencimiento!,
                    fechaIngreso: Value(DateTime.now()),
                    stockActual: Value(row.stockInicial),
                    precioCompraCaja: Value(row.costoCaja),
                    precioCompraUnitario: Value(
                      row.unidadesPorCaja > 0 ? (row.costoCaja / row.unidadesPorCaja) : row.costoCaja,
                    ),
                    ubicacion: Value(row.ubicacion),
                  ),
                );
            batchesCreated++;
          }

          // Auditoría en Movimientos de Stock (Kardex)
          await db.into(db.movimientosStockTable).insert(
                MovimientosStockTableCompanion.insert(
                  tipo: 'ajuste_positivo',
                  loteId: batchId,
                  cantidad: row.stockInicial,
                  documentoReferencia: const Value('CARGA_INICIAL'),
                  fechaMovimiento: Value(DateTime.now()),
                  observaciones: const Value('Carga Masiva de Inventario inicial desde archivo Excel/CSV'),
                ),
              );
        }
      }
    });

    final duration = DateTime.now().difference(startTime);

    return CatalogImportSummary(
      totalRows: rows.length,
      validRows: rows.where((r) => r.isValid).length,
      errorRows: rows.where((r) => !r.isValid).length,
      productsCreated: productsCreated,
      productsUpdated: productsUpdated,
      batchesCreated: batchesCreated,
      rows: rows,
      executionDuration: duration,
    );
  }

  // --- Helpers de Parseo Defensivo ---

  static double _parseDouble(String? raw, {double defaultValue = 0.0}) {
    if (raw == null) return defaultValue;
    var sanitized = raw.replaceAll(r'$', '').replaceAll(' ', '').trim();
    sanitized = sanitized.replaceAll(',', '.');
    return double.tryParse(sanitized) ?? defaultValue;
  }

  static int _parseInt(String? raw, {int defaultValue = 1}) {
    if (raw == null) return defaultValue;
    final sanitized = raw.replaceAll(' ', '').trim();
    return int.tryParse(sanitized) ?? defaultValue;
  }

  static bool _parseBool(String? raw, {bool defaultValue = false}) {
    if (raw == null) return defaultValue;
    final clean = raw.trim().toUpperCase();
    if (clean == 'SI' || clean == 'S' || clean == 'TRUE' || clean == '1' || clean == 'YES' || clean == 'Y') {
      return true;
    }
    if (clean == 'NO' || clean == 'N' || clean == 'FALSE' || clean == '0') {
      return false;
    }
    return defaultValue;
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    final clean = raw.trim();
    if (clean.isEmpty) return null;

    // Formato estándar ISO: YYYY-MM-DD
    final isoDate = DateTime.tryParse(clean);
    if (isoDate != null) return isoDate;

    // Formatos con barras o guiones comunes en Ecuador: DD/MM/YYYY o DD-MM-YYYY
    final parts = clean.contains('/') ? clean.split('/') : clean.split('-');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        // YYYY/MM/DD
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          return DateTime(year, month, day);
        }
      } else if (parts[2].length == 4) {
        // DD/MM/YYYY
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }
}
