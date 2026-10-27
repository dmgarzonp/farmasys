import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sri_soap_client.dart';
import 'sri_xml_generator.dart';
import 'sri_signature_service.dart';
import 'sri_access_key_generator.dart';
import '../../data/repositories/sri_queue_repository.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';
import '../../../../core/licensing/application/license_service.dart';

final sriBackgroundWorkerProvider = Provider<SriBackgroundWorker>((ref) {
  final worker = SriBackgroundWorker(ref);
  ref.onDispose(() => worker.stop());
  return worker;
});

/// Demonio (Background Worker) que transmite y autoriza comprobantes con el SRI asíncronamente
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

    final license = _ref.read(licenseServiceProvider).asData?.value;
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
        // --- 1. Generación de XML, Firma XAdES-BES y Recepción SRI ---
        if (invoice.estadoSri == 'pendiente') {
          final fullData = await queueRepo.getInvoiceFullData(invoice.id);
          final sequential = invoice.id.toString().padLeft(9, '0');
          final numericCode = ((invoice.id * 7919) % 90000000 + 10000000).toString();

          final accessKey = invoice.claveAcceso ??
              SriAccessKeyGenerator.generate(
                date: invoice.fechaVenta,
                documentType: '01', // Factura
                ruc: settings.sriRuc,
                environment: settings.sriAmbiente,
                establishment: settings.sriEstablecimiento,
                emissionPoint: settings.sriPuntoEmision,
                sequential: sequential,
                numericCode: numericCode,
              );

          final cliente = fullData?.cliente;
          final customerName = cliente?.nombreCompleto ?? 'CONSUMIDOR FINAL';
          final customerIdType = cliente?.tipoDocumento ?? '07';
          final customerId = cliente?.documento ?? '9999999999999';
          final customerEmail = cliente?.email;

          final totalWithoutTax = invoice.subtotal0 + invoice.subtotal15;
          final ivaPercentage = settings.ivaVigente;
          final ivaValue = invoice.impuestoTotal;

          final details = (fullData != null && fullData.details.isNotEmpty)
              ? fullData.details
              : [
                  InvoiceDetail(
                    code: 'GEN-01',
                    description: 'VENTA GENERAL DE FARMACIA',
                    quantity: 1.0,
                    unitPrice: totalWithoutTax,
                    discount: invoice.descuentoTotal,
                    totalWithoutTax: totalWithoutTax,
                  ),
                ];

          final rawXml = SriXmlGenerator.generateInvoiceXml(
            accessKey: accessKey,
            date: invoice.fechaVenta,
            ruc: settings.sriRuc,
            businessName: settings.sriRazonSocial.isNotEmpty
                ? settings.sriRazonSocial
                : settings.pharmacyName,
            establishment: settings.sriEstablecimiento,
            emissionPoint: settings.sriPuntoEmision,
            sequential: sequential,
            environment: settings.sriAmbiente,
            customerName: customerName,
            customerIdType: customerIdType,
            customerId: customerId,
            totalWithoutTax: totalWithoutTax,
            totalDiscount: invoice.descuentoTotal,
            totalWithTax: invoice.total,
            ivaPercentage: ivaPercentage,
            ivaValue: ivaValue,
            details: details,
            customerEmail: customerEmail,
          );

          // Firmar digitalmente con el motor nativo XAdES-BES
          final signedXml = await SriSignatureService.signXmlXadesBes(
            xmlContent: rawXml,
            p12FilePath: settings.sriFirmaPath,
            p12Password: settings.sriFirmaPassword,
          );

          // Codificar en Base64 para el Web Service SOAP de Recepción
          final signedXmlBase64 = base64.encode(utf8.encode(signedXml));

          // Transmitir al Web Service de Recepción
          final response = await SriSoapClient.sendReceipt(
            signedXmlBase64: signedXmlBase64,
            environment: settings.sriAmbiente,
          );

          if (response['success'] == true) {
            await queueRepo.updateSriStatus(
              ventaId: invoice.id,
              estadoSri: 'recibida',
              claveAcceso: accessKey,
              mensajeSri: 'Comprobante recibido por el SRI, en cola de autorización',
            );
          } else {
            final errorDetalle = (response['mensaje'] ?? response['estado'] ?? 'Error en recepción').toString();
            await queueRepo.updateSriStatus(
              ventaId: invoice.id,
              estadoSri: 'rechazado',
              claveAcceso: accessKey,
              mensajeSri: errorDetalle,
            );
          }
        }
        // --- 2. Consulta de Autorización SRI (Si fue recibida previamente) ---
        else if (invoice.estadoSri == 'recibida' && invoice.claveAcceso != null) {
          final response = await SriSoapClient.requestAuthorization(
            accessKey: invoice.claveAcceso!,
            environment: settings.sriAmbiente,
          );

          if (response['success'] == true) {
            final numAuth = response['numeroAutorizacion']?.toString() ?? invoice.claveAcceso;
            final fechaAuth = response['fechaAutorizacion']?.toString() ?? '';
            final msg = fechaAuth.isNotEmpty ? 'AUTORIZADO ($fechaAuth)' : 'AUTORIZADO: $numAuth';

            await queueRepo.updateSriStatus(
              ventaId: invoice.id,
              estadoSri: 'autorizado',
              mensajeSri: msg,
            );
          } else {
            final estado = response['estado']?.toString();
            // Si el comprobante sigue "EN PROCESO", mantenemos el estado recibida para reintentar
            if (estado != 'EN PROCESO') {
              final errorDetalle = (response['mensaje'] ?? 'Rechazado en Autorización ($estado)').toString();
              await queueRepo.updateSriStatus(
                ventaId: invoice.id,
                estadoSri: 'rechazado',
                mensajeSri: errorDetalle,
              );
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error en el Background Worker del SRI: $e');
      }
    } finally {
      _isRunning = false;
    }
  }
}
