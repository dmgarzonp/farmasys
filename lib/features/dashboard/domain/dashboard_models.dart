class AlertaCaducidad {
  final int loteId;
  final String productoNombre;
  final String presentacionNombre;
  final String lote;
  final DateTime fechaVencimiento;
  final double stockActual;

  AlertaCaducidad({
    required this.loteId,
    required this.productoNombre,
    required this.presentacionNombre,
    required this.lote,
    required this.fechaVencimiento,
    required this.stockActual,
  });

  /// Retorna los días restantes hasta la caducidad
  int get diasRestantes {
    final hoy = DateTime.now();
    return fechaVencimiento.difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
  }

  /// Indica la criticidad de la alerta
  /// Roja: <= 30 días, Amarilla: <= 90 días, Verde: > 90 días
  String get nivelCriticidad {
    if (diasRestantes <= 30) return 'Alta';
    if (diasRestantes <= 90) return 'Media';
    return 'Baja';
  }
}

class AlertaStock {
  final String productoNombre;
  final String presentacionNombre;
  final int stockMinimo;
  final double stockTotal;

  AlertaStock({
    required this.productoNombre,
    required this.presentacionNombre,
    required this.stockMinimo,
    required this.stockTotal,
  });

  bool get esCritico => stockTotal <= (stockMinimo / 2);
}

class ProductoTop {
  final String productoNombre;
  final String presentacionNombre;
  final double cantidadVendida;
  final double totalRecaudado;

  ProductoTop({
    required this.productoNombre,
    required this.presentacionNombre,
    required this.cantidadVendida,
    required this.totalRecaudado,
  });
}

