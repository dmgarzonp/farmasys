/// Constantes y especificaciones del Servicio de Rentas Internas (SRI) Ecuador
class SriConstants {
  SriConstants._();

  // Ambientes del SRI
  static const String ambientePruebas = '1';
  static const String ambienteProduccion = '2';

  // Tipo de emisión
  static const String emisionNormal = '1';

  // Tipos de comprobantes electrónicos
  static const String tipoFactura = '01';
  static const String tipoNotaCredito = '04';
  static const String tipoNotaDebito = '05';
  static const String tipoGuiaRemision = '06';
  static const String tipoComprobanteRetencion = '07';

  // Códigos de porcentaje de IVA según tabla 17 del SRI
  static const String codigoIva0 = '0';
  static const String codigoIva15 = '4'; // Tarifa IVA 15%
  static const String codigoIvaNoObjeto = '6';
  static const String codigoIvaExento = '7';

  // Endpoints oficiales Web Services SOAP del SRI
  static const String urlRecepcionPruebas =
      'https://celcer.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl';
  static const String urlAutorizacionPruebas =
      'https://celcer.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl';

  static const String urlRecepcionProduccion =
      'https://cel.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl';
  static const String urlAutorizacionProduccion =
      'https://cel.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl';
}

/// Formas de pago del SRI (Tabla 24 Ficha Técnica)
enum SriPaymentMethod {
  efectivo('01', 'Sin utilización del sistema financiero (Efectivo)'),
  compensacion('15', 'Compensación de deudas'),
  tarjetaDebito('16', 'Tarjeta de Débito'),
  dineroElectronico('17', 'Dinero Electrónico'),
  tarjetaPrepago('18', 'Tarjeta Prepago'),
  tarjetaCredito('19', 'Tarjeta de Crédito'),
  transferencia('20', 'Otros con utilización del sistema financiero (Transferencia/Cheque)'),
  endoso('21', 'Endoso de títulos');

  final String code;
  final String label;
  const SriPaymentMethod(this.code, this.label);
}
