/// Constantes generales del sistema FarmSys
class AppConstants {
  AppConstants._();

  static const String appName = 'FarmSys';
  static const String appSubtitle = 'Sistema Integral de Farmacia y POS';
  static const String appVersion = '1.0.0';

  // Configuración de Impresión Térmica
  static const int thermalPrinterWidth80mm = 48; // caracteres por línea estándar
  static const int thermalPrinterWidth58mm = 32;

  // Umbrales de Inventario y Alertas
  static const int defaultExpirationAlertDays = 30;
  static const int criticalExpirationAlertDays = 7;
  static const int defaultStockMinimo = 5;

  // Impuestos Ecuador
  static const double ivaVigente = 0.12; // IVA 12% (sugerido por el usuario)
  static const double ivaTarifaCero = 0.00;

  // Consumidor Final
  static const String consumidorFinalDocumento = '9999999999999';
  static const String consumidorFinalNombre = 'CONSUMIDOR FINAL';
  static const double montoMaximoConsumidorFinalSinDatos = 50.00;
}

/// Roles de usuario en FarmSys (Seguridad y permisos)
enum UserRole {
  administrador('Administrador', 'Acceso total a configuración, reportes y anulación'),
  farmaceutico('Farmacéutico', 'Ventas, compras, control de recetas ARCSA e inventario'),
  cajero('Cajero', 'Punto de venta, cobro y arqueo de caja'),
  almacen('Almacén', 'Recepción de mercadería, ajustes de stock y vencimientos');

  final String label;
  final String description;
  const UserRole(this.label, this.description);
}

/// Tipos de movimientos auditados en el Kardex
enum StockMovementType {
  entradaCompra('entrada_compra', 'Entrada por Recepción de Compra', true),
  salidaVenta('salida_venta', 'Salida por Venta en POS', false),
  ajustePositivo('ajuste_positivo', 'Ajuste Manual Favorable (+)', true),
  ajusteNegativo('ajuste_negativo', 'Ajuste Manual Desfavorable / Merma (-)', false),
  vencimiento('vencimiento', 'Baja por Medicamento Vencido (-)', false),
  devolucion('devolucion', 'Devolución de Cliente (+)', true);

  final String code;
  final String description;
  final bool isEntry;
  const StockMovementType(this.code, this.description, this.isEntry);
}
