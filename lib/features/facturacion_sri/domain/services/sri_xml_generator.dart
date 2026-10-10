import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import '../../../../core/database/app_database.dart'; // Para VentasTable, etc.

class SriXmlGenerator {
  /// Genera el XML de la factura según el estándar V2.1.0 del SRI
  static String generateInvoiceXml({
    required String accessKey,
    required DateTime date,
    required String ruc,
    required String businessName,
    required String establishment,
    required String emissionPoint,
    required String sequential,
    required int environment,
    required String customerName,
    required String customerIdType, // 04=RUC, 05=Cedula, 06=Pasaporte, 07=Consumidor Final
    required String customerId,
    required double totalWithoutTax,
    required double totalDiscount,
    required double totalWithTax,
    required double ivaPercentage,
    required double ivaValue,
    required List<InvoiceDetail> details,
  }) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    
    builder.element('factura', attributes: {'id': 'comprobante', 'version': '2.1.0'}, nest: () {
      
      // Información Tributaria (Cabecera Principal)
      builder.element('infoTributaria', nest: () {
        builder.element('ambiente', nest: environment.toString());
        builder.element('tipoEmision', nest: '1'); // 1 = Normal
        builder.element('razonSocial', nest: businessName);
        builder.element('nombreComercial', nest: businessName); // Simplificado
        builder.element('ruc', nest: ruc);
        builder.element('claveAcceso', nest: accessKey);
        builder.element('codDoc', nest: '01'); // 01 = Factura
        builder.element('estab', nest: establishment);
        builder.element('ptoEmi', nest: emissionPoint);
        builder.element('secuencial', nest: sequential);
        builder.element('dirMatriz', nest: 'Direccion Matriz'); // TODO: Tomar de Settings
      });

      // Información de la Factura
      builder.element('infoFactura', nest: () {
        builder.element('fechaEmision', nest: DateFormat('dd/MM/yyyy').format(date));
        builder.element('dirEstablecimiento', nest: 'Direccion Establecimiento');
        builder.element('obligadoContabilidad', nest: 'NO'); // TODO: Tomar de Settings
        builder.element('tipoIdentificacionComprador', nest: customerIdType);
        builder.element('razonSocialComprador', nest: customerName);
        builder.element('identificacionComprador', nest: customerId);
        builder.element('totalSinImpuestos', nest: totalWithoutTax.toStringAsFixed(2));
        builder.element('totalDescuento', nest: totalDiscount.toStringAsFixed(2));

        // Impuestos
        builder.element('totalConImpuestos', nest: () {
          builder.element('totalImpuesto', nest: () {
            builder.element('codigo', nest: '2'); // 2 = IVA
            
            // Código de porcentaje: 2=12%, 3=14%, 4=15%, 0=0% (Simplificado, revisar tabla SRI oficial)
            String percentageCode = '0';
            if (ivaPercentage == 0.12) percentageCode = '2';
            else if (ivaPercentage == 0.15) percentageCode = '4';
            
            builder.element('codigoPorcentaje', nest: percentageCode);
            builder.element('baseImponible', nest: totalWithoutTax.toStringAsFixed(2));
            builder.element('valor', nest: ivaValue.toStringAsFixed(2));
          });
        });

        builder.element('propina', nest: '0.00');
        builder.element('importeTotal', nest: totalWithTax.toStringAsFixed(2));
        builder.element('moneda', nest: 'DOLAR');
        
        // Pagos
        builder.element('pagos', nest: () {
          builder.element('pago', nest: () {
            builder.element('formaPago', nest: '01'); // 01 = Sin utilizacion del sistema financiero (Efectivo)
            builder.element('total', nest: totalWithTax.toStringAsFixed(2));
            builder.element('plazo', nest: '1');
            builder.element('unidadTiempo', nest: 'dias');
          });
        });
      });

      // Detalles
      builder.element('detalles', nest: () {
        for (final item in details) {
          builder.element('detalle', nest: () {
            builder.element('codigoPrincipal', nest: item.code);
            builder.element('descripcion', nest: item.description);
            builder.element('cantidad', nest: item.quantity.toStringAsFixed(2));
            builder.element('precioUnitario', nest: item.unitPrice.toStringAsFixed(2));
            builder.element('descuento', nest: item.discount.toStringAsFixed(2));
            builder.element('precioTotalSinImpuesto', nest: item.totalWithoutTax.toStringAsFixed(2));

            builder.element('impuestos', nest: () {
              builder.element('impuesto', nest: () {
                builder.element('codigo', nest: '2'); // 2 = IVA
                
                String percentageCode = '0';
                if (ivaPercentage == 0.12) percentageCode = '2';
                else if (ivaPercentage == 0.15) percentageCode = '4';
                
                builder.element('codigoPorcentaje', nest: percentageCode);
                builder.element('tarifa', nest: (ivaPercentage * 100).toStringAsFixed(0));
                builder.element('baseImponible', nest: item.totalWithoutTax.toStringAsFixed(2));
                builder.element('valor', nest: (item.totalWithoutTax * ivaPercentage).toStringAsFixed(2));
              });
            });
          });
        }
      });
      
      // Adicionales (Opcional)
      builder.element('infoAdicional', nest: () {
        builder.element('campoAdicional', attributes: {'nombre': 'Email'}, nest: 'cliente@ejemplo.com');
      });

    });

    return builder.buildDocument().toXmlString(pretty: true);
  }
}

class InvoiceDetail {
  final String code;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double totalWithoutTax;

  InvoiceDetail({
    required this.code,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.totalWithoutTax,
  });
}
