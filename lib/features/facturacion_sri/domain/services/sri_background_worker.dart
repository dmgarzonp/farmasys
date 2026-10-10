import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sri_soap_client.dart';
import 'sri_xml_generator.dart';
import 'sri_signature_service.dart';
import 'sri_access_key_generator.dart';
import '../data/repositories/sri_queue_repository.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';
import '../../../../core/licensing/application/license_service.dart';

final sriBackgroundWorkerProvider = Provider<SriBackgroundWorker>((ref) {
  final worker = SriBackgroundWorker(ref);
  ref.onDispose(() => worker.stop());
  return worker;
});

/// Demonio (Background Worker) que transmite comprobantes al SRI asíncronamente
class SriBackgroundWorker {
  final Ref _ref;
  Timer? _timer;
  bool _isRunning = false;

  SriBackgroundWorker(this._ref);

  void start() {
    if (_timer != null && _timer!.isActive) return;
    
    // Ejecutar cada 15 segundos
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _processQueue();
    });
    
    // Ejecutar la primera vez inmediatamente
    _processQueue();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _processQueue() async {
    // Evitar ejecuciones simultáneas si el proceso anterior no ha terminado
    if (_isRunning) return;
    
    final license = _ref.read(licenseServiceProvider).valueOrNull;
    if (license == null || !license.isPremium) {
      return; // No procesar si no hay licencia premium activa
    }

    _isRunning = true;
    try {
      final queueRepo = _ref.read(sriQueueRepositoryProvider);
      final settings = _ref.read(settingsProvider);

      // Si no están configurados los datos obligatorios, ignorar
      if (settings.sriRuc.isEmpty || settings.sriFirmaPath.isEmpty) {
        return;
      }

      final pendingInvoices = await queueRepo.getPendingInvoices();
      
      for (final invoice in pendingInvoices) {
        // --- 1. Generación de XML y Clave de Acceso (Si está pendiente) ---
        if (invoice.estadoSri == 'pendiente') {
           // Lógica abreviada: En producción, aquí consultaríamos el detalle de la venta 
           // e invocaríamos a SriXmlGenerator.generateInvoiceXml(...)
           
           final accessKey = SriAccessKeyGenerator.generate(
             date: invoice.fechaVenta,
             documentType: '01', // Factura
             ruc: settings.sriRuc,
             environment: settings.sriAmbiente,
             establishment: settings.sriEstablecimiento,
             emissionPoint: settings.sriPuntoEmision,
             sequential: invoice.id.toString(), // Idealmente un secuencial guardado independiente del ID
             numericCode: '12345678', // Código aleatorio
           );

           // STUB: xml generado
           final rawXml = '<factura><infoTributaria><claveAcceso>\$accessKey</claveAcceso></infoTributaria></factura>';
           
           // Firmar XML
           final signedXml = await SriSignatureService.signXmlXadesBes(
             xmlContent: rawXml,
             p12FilePath: settings.sriFirmaPath,
             p12Password: settings.sriFirmaPassword,
           );

           // Enviar a Recepción
           final response = await SriSoapClient.sendReceipt(
             signedXmlBase64: signedXml, // Aquí en realidad sería un base64 encode o como requiera la librería
             environment: settings.sriAmbiente,
           );

           if (response['success'] == true) {
             await queueRepo.updateSriStatus(
               ventaId: invoice.id,
               estadoSri: 'recibida',
               claveAcceso: accessKey,
               mensajeSri: 'Comprobante recibido por el SRI, esperando autorización',
             );
           } else {
              // Manejo de errores (ej. clave acceso registrada, error estructura)
             await queueRepo.updateSriStatus(
               ventaId: invoice.id,
               estadoSri: 'rechazado',
               mensajeSri: response['estado'] ?? 'Error desconocido en Recepción',
             );
           }
        } 
        
        // --- 2. Autorización (Si fue recibida previamente) ---
        else if (invoice.estadoSri == 'recibida' && invoice.claveAcceso != null) {
          final response = await SriSoapClient.requestAuthorization(
             accessKey: invoice.claveAcceso!,
             environment: settings.sriAmbiente,
          );

          if (response['success'] == true) {
             await queueRepo.updateSriStatus(
               ventaId: invoice.id,
               estadoSri: 'autorizado',
               mensajeSri: "AUTORIZADO: \${response['numeroAutorizacion']}",
             );
          } else {
             // Si el SRI dice en proceso, mantenemos recibida. Si da error, rechazado.
             final estado = response['estado'];
             if (estado != 'EN PROCESO') {
               await queueRepo.updateSriStatus(
                 ventaId: invoice.id,
                 estadoSri: 'rechazado',
                 mensajeSri: 'Rechazado en Autorización',
               );
             }
          }
        }
      }
    } catch (e) {
      print('Error en el Background Worker del SRI: \$e');
    } finally {
      _isRunning = false;
    }
  }
}
