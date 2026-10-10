import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Cliente SOAP para comunicarse con los Web Services del SRI
class SriSoapClient {
  // URLs del SRI para Entorno de Pruebas (1)
  static const String _urlRecepcionPruebas = 'https://celcer.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl';
  static const String _urlAutorizacionPruebas = 'https://celcer.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl';

  // URLs del SRI para Entorno de Producción (2)
  static const String _urlRecepcionProduccion = 'https://cel.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl';
  static const String _urlAutorizacionProduccion = 'https://cel.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl';

  /// Envía el XML firmado al Web Service de Recepción del SRI.
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
        // En producción se debe parsear la respuesta XML del SRI (RespuestaSolicitud)
        final document = XmlDocument.parse(response.body);
        final estado = document.findAllElements('estado').firstOrNull?.innerText ?? 'DESCONOCIDO';
        
        return {
          'success': estado == 'RECIBIDA',
          'estado': estado,
          'raw': response.body,
        };
      } else {
        return {
          'success': false,
          'estado': 'HTTP_ERROR_${response.statusCode}',
          'raw': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'estado': 'NETWORK_ERROR',
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
        
        return {
          'success': estado == 'AUTORIZADO',
          'estado': estado,
          'numeroAutorizacion': numAutorizacion,
          'raw': response.body,
        };
      } else {
        return {
          'success': false,
          'estado': 'HTTP_ERROR_${response.statusCode}',
          'raw': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'estado': 'NETWORK_ERROR',
        'raw': e.toString(),
      };
    }
  }
}
