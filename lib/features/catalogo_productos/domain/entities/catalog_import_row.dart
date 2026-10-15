import 'package:equatable/equatable.dart';

/// Representa una fila individual leída desde el archivo CSV de importación masiva.
class CatalogImportRow extends Equatable {
  final int rowNumber;
  final String? codigoBarras;
  final String nombreComercial;
  final String? principioActivo;
  final String? concentracion;
  final String presentacion;
  final int unidadesPorCaja;
  final double costoCaja;
  final double precioVentaCaja;
  final double precioVentaFraccion;
  final bool tieneIva;
  final String? lote;
  final DateTime? fechaVencimiento;
  final double stockInicial;
  final String? ubicacion;
  final bool requiereReceta;
  final bool esPsicotropico;
  final bool esAntibiotico;
  final List<String> errors;

  const CatalogImportRow({
    required this.rowNumber,
    this.codigoBarras,
    required this.nombreComercial,
    this.principioActivo,
    this.concentracion,
    this.presentacion = 'Caja x 1',
    this.unidadesPorCaja = 1,
    this.costoCaja = 0.0,
    required this.precioVentaCaja,
    this.precioVentaFraccion = 0.0,
    this.tieneIva = false,
    this.lote,
    this.fechaVencimiento,
    this.stockInicial = 0.0,
    this.ubicacion,
    this.requiereReceta = false,
    this.esPsicotropico = false,
    this.esAntibiotico = false,
    this.errors = const [],
  });

  bool get isValid => errors.isEmpty;
  bool get hasStock => stockInicial > 0;

  CatalogImportRow copyWith({
    int? rowNumber,
    String? codigoBarras,
    String? nombreComercial,
    String? principioActivo,
    String? concentracion,
    String? presentacion,
    int? unidadesPorCaja,
    double? costoCaja,
    double? precioVentaCaja,
    double? precioVentaFraccion,
    bool? tieneIva,
    String? lote,
    DateTime? fechaVencimiento,
    double? stockInicial,
    String? ubicacion,
    bool? requiereReceta,
    bool? esPsicotropico,
    bool? esAntibiotico,
    List<String>? errors,
  }) {
    return CatalogImportRow(
      rowNumber: rowNumber ?? this.rowNumber,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      principioActivo: principioActivo ?? this.principioActivo,
      concentracion: concentracion ?? this.concentracion,
      presentacion: presentacion ?? this.presentacion,
      unidadesPorCaja: unidadesPorCaja ?? this.unidadesPorCaja,
      costoCaja: costoCaja ?? this.costoCaja,
      precioVentaCaja: precioVentaCaja ?? this.precioVentaCaja,
      precioVentaFraccion: precioVentaFraccion ?? this.precioVentaFraccion,
      tieneIva: tieneIva ?? this.tieneIva,
      lote: lote ?? this.lote,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      stockInicial: stockInicial ?? this.stockInicial,
      ubicacion: ubicacion ?? this.ubicacion,
      requiereReceta: requiereReceta ?? this.requiereReceta,
      esPsicotropico: esPsicotropico ?? this.esPsicotropico,
      esAntibiotico: esAntibiotico ?? this.esAntibiotico,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        rowNumber,
        codigoBarras,
        nombreComercial,
        principioActivo,
        concentracion,
        presentacion,
        unidadesPorCaja,
        costoCaja,
        precioVentaCaja,
        precioVentaFraccion,
        tieneIva,
        lote,
        fechaVencimiento,
        stockInicial,
        ubicacion,
        requiereReceta,
        esPsicotropico,
        esAntibiotico,
        errors,
      ];
}

/// Resumen estadístico del proceso de importación
class CatalogImportSummary {
  final int totalRows;
  final int validRows;
  final int errorRows;
  final int productsCreated;
  final int productsUpdated;
  final int batchesCreated;
  final List<CatalogImportRow> rows;
  final Duration executionDuration;

  const CatalogImportSummary({
    required this.totalRows,
    required this.validRows,
    required this.errorRows,
    required this.productsCreated,
    required this.productsUpdated,
    required this.batchesCreated,
    required this.rows,
    required this.executionDuration,
  });
}

