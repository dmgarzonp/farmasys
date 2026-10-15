import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/app_buttons.dart';
import '../../../../shared/components/app_snackbars.dart';
import '../../../../shared/components/xela_badge.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../../inventario/presentation/controllers/inventory_notifier.dart';
import '../controllers/product_catalog_notifier.dart';
import '../../domain/entities/catalog_import_row.dart';
import '../../domain/services/catalog_import_service.dart';

/// Modal ergonómico de escritorio para importación masiva de medicamentos e inventario
class CatalogImportDialog extends ConsumerStatefulWidget {
  const CatalogImportDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CatalogImportDialog(),
    );
  }

  @override
  ConsumerState<CatalogImportDialog> createState() => _CatalogImportDialogState();
}

class _CatalogImportDialogState extends ConsumerState<CatalogImportDialog> {
  String? _selectedFileName;
  List<CatalogImportRow> _parsedRows = [];
  bool _isLoading = false;
  bool _isImporting = false;
  bool _skipInvalid = true;
  CatalogImportSummary? _importSummary;

  Future<void> _downloadTemplate() async {
    try {
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar Plantilla de Importación FarmSys',
        fileName: 'plantilla_inventario_farmsys.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        var filePath = outputFile;
        if (!filePath.toLowerCase().endsWith('.csv')) {
          filePath = '$filePath.csv';
        }
        await CatalogImportService.saveTemplateToFile(filePath);
        if (mounted) {
          AppSnackBars.showSuccess(
            context,
            message: 'Plantilla guardada en: $filePath. Ábrela en Excel para llenarla.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.showError(
          context,
          message: 'Error al exportar plantilla: $e',
        );
      }
    }
  }

  Future<void> _pickAndParseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'tsv'],
        dialogTitle: 'Seleccionar Archivo de Inventario (Excel / CSV)',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        setState(() {
          _isLoading = true;
          _selectedFileName = result.files.single.name;
          _importSummary = null;
        });

        final rawContent = await file.readAsString();
        final rows = CatalogImportService.parseAndValidateCsv(rawContent);

        setState(() {
          _parsedRows = rows;
          _isLoading = false;
        });

        if (rows.isEmpty && mounted) {
          AppSnackBars.showWarning(
            context,
            message: 'El archivo está vacío o no contiene filas con datos válidos.',
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackBars.showError(
          context,
          message: 'Error al leer el archivo: $e',
        );
      }
    }
  }

  Future<void> _executeImport() async {
    final validRows = _parsedRows.where((r) => r.isValid).toList();
    if (validRows.isEmpty) {
      AppSnackBars.showError(
        context,
        message: 'No hay filas válidas para importar.',
      );
      return;
    }

    setState(() => _isImporting = true);

    try {
      final db = ref.read(appDatabaseProvider);
      final summary = await CatalogImportService.executeImport(
        rows: _parsedRows,
        db: db,
        skipInvalid: _skipInvalid,
      );

      // Recargar proveedores reactivos de catálogo e inventario
      await ref.read(productCatalogProvider.notifier).loadProducts();
      await ref.read(inventoryProvider.notifier).loadBatches();

      setState(() {
        _isImporting = false;
        _importSummary = summary;
      });

      if (mounted) {
        AppSnackBars.showSuccess(
          context,
          message: '¡Importación completada! ${summary.productsCreated + summary.productsUpdated} medicamentos y ${summary.batchesCreated} lotes actualizados.',
        );
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        AppSnackBars.showError(
          context,
          message: 'Ocurrió un error durante la importación en base de datos: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final totalRows = _parsedRows.length;
    final validRows = _parsedRows.where((r) => r.isValid).length;
    final invalidRows = totalRows - validRows;

    return Dialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              _buildHeader(colors),
              const SizedBox(height: 16),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 16),

              // Barra de Acciones: Descarga de plantilla y selección de archivo
              _buildTopActions(colors),
              const SizedBox(height: 16),

              // Contenido Principal
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _importSummary != null
                        ? _buildSummaryView(colors)
                        : _parsedRows.isEmpty
                            ? _buildEmptyGuide(colors)
                            : _buildPreviewContent(colors, totalRows, validRows, invalidRows),
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 16),

              // Botones de Pie
              _buildBottomActions(colors, validRows),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.file_upload_outlined, color: colors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Importador Masivo de Catálogo e Inventario (Excel / CSV)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Carga tus medicamentos, presentaciones, precios y lotes iniciales de forma automática.',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textMuted),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Widget _buildTopActions(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          AppSecondaryButton(
            text: 'Descargar Plantilla CSV',
            icon: Icons.download_rounded,
            onPressed: _downloadTemplate,
          ),
          const SizedBox(width: 12),
          AppPrimaryButton(
            text: 'Seleccionar Archivo CSV',
            icon: Icons.folder_open_rounded,
            onPressed: _pickAndParseFile,
          ),
          const SizedBox(width: 16),
          if (_selectedFileName != null) ...[
            Icon(Icons.description_outlined, size: 16, color: colors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _selectedFileName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                'Acepta archivos CSV delimitados por punto y coma (;) o comas (,).',
                style: TextStyle(fontSize: 11, color: colors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyGuide(AppThemeColors colors) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: colors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Instrucciones de Carga Rápida',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStepItem(
                step: '1',
                title: 'Descarga la Plantilla Oficial',
                description:
                    'Haz clic en "Descargar Plantilla CSV" para obtener el formato exacto con ejemplos reales.',
                colors: colors,
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                step: '2',
                title: 'Abre y llena los datos en Excel',
                description:
                    'Copia o ingresa tus medicamentos. Las columnas requeridas son NOMBRE_COMERCIAL y PVP_CAJA. Si indicas stock, incluye FECHA_VENCIMIENTO.',
                colors: colors,
              ),
              const SizedBox(height: 12),
              _buildStepItem(
                step: '3',
                title: 'Selecciona el archivo para previsualizar',
                description:
                    'El sistema validará cada fila en tiempo real, señalando advertencias antes de tocar la base de datos.',
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String step,
    required String title,
    required String description,
    required AppThemeColors colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: colors.primarySurface,
          child: Text(
            step,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewContent(
    AppThemeColors colors,
    int totalRows,
    int validRows,
    int invalidRows,
  ) {
    return Column(
      children: [
        // Resumen de Validación
        Row(
          children: [
            XelaBadge(
              text: '$totalRows Filas detectadas',
              variant: XelaBadgeVariant.neutral,
            ),
            const SizedBox(width: 8),
            XelaBadge(
              text: '$validRows Válidas para ingresar',
              variant: XelaBadgeVariant.success,
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(width: 8),
            if (invalidRows > 0)
              XelaBadge(
                text: '$invalidRows Con errores',
                variant: XelaBadgeVariant.danger,
                icon: Icons.error_outline_rounded,
              ),
            const Spacer(),
            Row(
              children: [
                Switch(
                  value: _skipInvalid,
                  onChanged: (val) => setState(() => _skipInvalid = val),
                ),
                const SizedBox(width: 6),
                Text(
                  'Omitir filas con error e importar las válidas',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tabla de Previsualización
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 18,
                    headingRowHeight: 38,
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 44,
                    headingRowColor: MaterialStateProperty.all(colors.sidebarBg),
                    columns: const [
                      DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('# Fila', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Código Barras', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nombre Comercial', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Presentación', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Costo', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('PVP', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('IVA', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Lote', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _parsedRows.map((row) {
                      final hasError = !row.isValid;

                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>((states) {
                          if (hasError) return AppColors.error.withOpacity(0.06);
                          return null;
                        }),
                        cells: [
                          DataCell(
                            hasError
                                ? Tooltip(
                                    message: row.errors.join('\n'),
                                    child: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 18),
                                  )
                                : const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                          ),
                          DataCell(Text(row.rowNumber.toString())),
                          DataCell(Text(row.codigoBarras ?? '-')),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 220),
                              child: Text(
                                row.nombreComercial,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(row.presentacion)),
                          DataCell(Text(AppFormatters.currency(row.costoCaja))),
                          DataCell(Text(AppFormatters.currency(row.precioVentaCaja))),
                          DataCell(Text(row.tieneIva ? '15%' : '0%')),
                          DataCell(Text(row.lote ?? '-')),
                          DataCell(Text(row.fechaVencimiento != null ? AppFormatters.date(row.fechaVencimiento!) : '-')),
                          DataCell(
                            Text(
                              row.stockInicial > 0 ? row.stockInicial.toInt().toString() : '0',
                              style: TextStyle(
                                fontWeight: row.stockInicial > 0 ? FontWeight.bold : FontWeight.normal,
                                color: row.stockInicial > 0 ? colors.primary : colors.textMuted,
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
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(AppThemeColors colors) {
    final s = _importSummary!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.task_alt_rounded, color: AppColors.success, size: 54),
              const SizedBox(height: 14),
              Text(
                '¡Importación Masiva Exitosa!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Se procesaron ${s.validRows} registros en ${s.executionDuration.inMilliseconds} ms.',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    _buildStatLine('Medicamentos Nuevos Creados:', s.productsCreated.toString(), colors),
                    const Divider(height: 12),
                    _buildStatLine('Medicamentos Actualizados:', s.productsUpdated.toString(), colors),
                    const Divider(height: 12),
                    _buildStatLine('Lotes Físicos con Trazabilidad FEFO:', s.batchesCreated.toString(), colors),
                    if (s.errorRows > 0) ...[
                      const Divider(height: 12),
                      _buildStatLine('Filas Omitidas por Error:', s.errorRows.toString(), colors, isError: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                text: 'Aceptar y Ver Catálogo',
                icon: Icons.check,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatLine(String label, String value, AppThemeColors colors, {bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isError ? AppColors.error : colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(AppThemeColors colors, int validRows) {
    if (_importSummary != null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppSecondaryButton(
          text: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        if (_parsedRows.isNotEmpty)
          AppPrimaryButton(
            text: _isImporting
                ? 'Importando en Base de Datos...'
                : 'Iniciar Importación ($validRows Medicamentos)',
            icon: Icons.play_arrow_rounded,
            isLoading: _isImporting,
            onPressed: (validRows > 0 && !_isImporting) ? _executeImport : null,
          ),
      ],
    );
  }
}
