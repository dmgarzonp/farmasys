import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Cliente SOAP para comunicarse con los Web Services del SRI
class SriSoapClient {
  // URLs del SRI para Entorno de Pruebas (1)
  static const String _urlRecepcionPruebas =
      'https://celcer.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl';
  static const String _urlAutorizacionPruebas =
      'https://celcer.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl';

  // URLs del SRI para Entorno de Producción (2)
  static const String _urlRecepcionProduccion =
      'https://cel.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl';
  static const String _urlAutorizacionProduccion =
      'https://cel.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl';

  /// Envía el XML firmado en Base64 al Web Service de Recepción del SRI.
  static Future<Map<String, dynamic>> sendReceipt({
    required String signedXmlBase64,
    required int environment,
  }) async {
    final endpoint = environment == 1 ? _urlRecepcionPruebas : _urlRecepcionProduccion;

    final soapEnvelope = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ec="http://ec.gob.sri.ws.recepcion">
   <soapenv:Header/>
   <soapenv:Body>
      <ec:validarComprobante>
         <xml>$signedXmlBase64</xml>
      </ec:validarComprobante>
   </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      final response = await http.post(
        Uri.parse(endpoint.replaceAll('?wsdl', '')),
        headers: {
          'Content-Type': 'text/xml;charset=UTF-8',
          'SOAPAction': '',
        },
        body: utf8.encode(soapEnvelope),
      );

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final estado = document.findAllElements('estado').firstOrNull?.innerText ?? 'DESCONOCIDO';
        final mensajeDetalle = _extractMessages(document);

        return {
          'success': estado == 'RECIBIDA',
          'estado': estado,
          'mensaje': mensajeDetalle,
          'raw': response.body,
        };
      } else {
        return {
          'success': false,
          'estado': 'HTTP_ERROR_${response.statusCode}',
          'mensaje': 'Error HTTP en servidor SRI (${response.statusCode})',
          'raw': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'estado': 'NETWORK_ERROR',
        'mensaje': 'Error de conexión de red con el SRI: $e',
        'raw': e.toString(),
      };
    }
  }

  /// Consulta el estado de autorización de un comprobante usando su Clave de Acceso.
  static Future<Map<String, dynamic>> requestAuthorization({
    required String accessKey,
    required int environment,
  }) async {
    final endpoint = environment == 1 ? _urlAutorizacionPruebas : _urlAutorizacionProduccion;

    final soapEnvelope = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ec="http://ec.gob.sri.ws.autorizacion">
   <soapenv:Header/>
   <soapenv:Body>
      <ec:autorizacionComprobante>
         <claveAccesoComprobante>$accessKey</claveAccesoComprobante>
      </ec:autorizacionComprobante>
   </soapenv:Body>
</soapenv:Envelope>
''';

    try {
      final response = await http.post(
        Uri.parse(endpoint.replaceAll('?wsdl', '')),
        headers: {
          'Content-Type': 'text/xml;charset=UTF-8',
          'SOAPAction': '',
        },
        body: utf8.encode(soapEnvelope),
      );

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final estado = document.findAllElements('estado').firstOrNull?.innerText ?? 'EN PROCESO';
        final numAutorizacion = document.findAllElements('numeroAutorizacion').firstOrNull?.innerText;
        final fechaAutorizacion = document.findAllElements('fechaAutorizacion').firstOrNull?.innerText;
        final mensajeDetalle = _extractMessages(document);

        return {
          'success': estado == 'AUTORIZADO',
          'estado': estado,
          'numeroAutorizacion': numAutorizacion,
          'fechaAutorizacion': fechaAutorizacion,
          'mensaje': mensajeDetalle,
          'raw': response.body,
        };
      } else {
        return {
          'success': false,
          'estado': 'HTTP_ERROR_${response.statusCode}',
          'mensaje': 'Error HTTP en consulta de autorización (${response.statusCode})',
          'raw': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'estado': 'NETWORK_ERROR',
        'mensaje': 'Error de red consultando autorización: $e',
        'raw': e.toString(),
      };
    }
  }

  static String? _extractMessages(XmlDocument doc) {
    final mensajeNodes = doc.findAllElements('mensaje').toList();
    if (mensajeNodes.isEmpty) return null;

    final parts = <String>[];
    for (final node in mensajeNodes) {
      final id = node.findElements('identificador').firstOrNull?.innerText;
      final msg = node.findElements('mensaje').firstOrNull?.innerText ?? node.innerText.trim();
      final info = node.findElements('informacionAdicional').firstOrNull?.innerText;

      final itemParts = <String>[];
      if (id != null && id.isNotEmpty) itemParts.add('[$id]');
      if (msg.isNotEmpty) itemParts.add(msg);
      if (info != null && info.isNotEmpty) itemParts.add('($info)');

      if (itemParts.isNotEmpty) {
        parts.add(itemParts.join(' '));
      }
    }

    return parts.isNotEmpty ? parts.join(' | ') : null;
  }
}
