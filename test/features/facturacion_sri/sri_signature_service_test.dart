import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart';
import 'package:xml/xml.dart';
import 'package:farmsys/features/facturacion_sri/domain/services/xml_c14n.dart';
import 'package:farmsys/features/facturacion_sri/domain/services/sri_signature_service.dart';
import 'package:farmsys/features/facturacion_sri/domain/services/sri_xml_generator.dart';

void main() {
  const p12Path = 'test/fixtures/test_signature.p12';
  const p12Pass = 'FarmSys2026!';

  group('XmlC14n Canonicalization (W3C Inclusive C14N)', () {
    test('Sorts attributes alphabetically and converts self-closing tags', () {
      const input = '<factura version="2.1.0" id="comprobante"><infoTributaria><ambiente>1</ambiente><empty/></infoTributaria></factura>';
      final doc = XmlDocument.parse(input);
      final c14n = XmlC14n.canonicalize(doc.rootElement);

      expect(
        c14n,
        equals('<factura id="comprobante" version="2.1.0"><infoTributaria><ambiente>1</ambiente><empty></empty></infoTributaria></factura>'),
      );
    });

    test('Sorts namespaces with default xmlns first, then alphabetically by prefix', () {
      const input = '<etsi:SignedProperties xmlns:etsi="http://uri.etsi.org/01903/v1.3.2#" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" Id="SignedProps"><etsi:SignedSignatureProperties></etsi:SignedSignatureProperties></etsi:SignedProperties>';
      final doc = XmlDocument.parse(input);
      final c14n = XmlC14n.canonicalize(doc.rootElement);

      expect(
        c14n,
        equals('<etsi:SignedProperties xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:etsi="http://uri.etsi.org/01903/v1.3.2#" Id="SignedProps"><etsi:SignedSignatureProperties></etsi:SignedSignatureProperties></etsi:SignedProperties>'),
      );
    });
  });

  group('SriSignatureService - P12 Validation', () {
    test('Successfully extracts certificate info from valid .p12', () async {
      final info = await SriSignatureService.validateP12File(
        p12FilePath: p12Path,
        p12Password: p12Pass,
      );

      expect(info.commonName, equals('PRUEBA SRI FARMSYS'));
      expect(info.rucOrIdentifier, equals('1799999999001'));
      expect(info.issuerDn, contains('CN=PRUEBA SRI FARMSYS'));
      expect(info.serialNumberHex, isNotEmpty);
      expect(info.serialNumberDec, isNotEmpty);
      expect(info.isExpired, isFalse);
      expect(info.isValid, isTrue);
      expect(info.daysUntilExpiration, greaterThan(300));
    });

    test('Throws error with incorrect password', () async {
      expect(
        () => SriSignatureService.validateP12File(
          p12FilePath: p12Path,
          p12Password: 'ClaveErronea123!',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Throws error when file does not exist', () async {
      expect(
        () => SriSignatureService.validateP12File(
          p12FilePath: 'ruta/inexistente/firma.p12',
          p12Password: '1234',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SriSignatureService - XAdES-BES Digital Signature Engine', () {
    late String sampleXml;

    setUp(() {
      sampleXml = SriXmlGenerator.generateInvoiceXml(
        accessKey: '2610202601179999999900110010010000000011234567819',
        date: DateTime(2026, 10, 26),
        ruc: '1799999999001',
        businessName: 'FARMACIA SAN RAFAEL',
        establishment: '001',
        emissionPoint: '001',
        sequential: '000000001',
        environment: 1,
        customerName: 'JUAN PEREZ',
        customerIdType: '05',
        customerId: '1712345678',
        totalWithoutTax: 20.00,
        totalDiscount: 0.00,
        totalWithTax: 23.00,
        ivaPercentage: 0.15,
        ivaValue: 3.00,
        details: [
          InvoiceDetail(
            code: 'MED-01',
            description: 'PARACETAMOL 500MG X 20 TAB',
            quantity: 2.0,
            unitPrice: 5.00,
            discount: 0.00,
            totalWithoutTax: 10.00,
          ),
          InvoiceDetail(
            code: 'MED-02',
            description: 'IBUPROFENO 600MG X 10 CAP',
            quantity: 2.0,
            unitPrice: 5.00,
            discount: 0.00,
            totalWithoutTax: 10.00,
          ),
        ],
        customerEmail: 'juan.perez@ejemplo.com',
      );
    });

    test('Signs XML with real XAdES-BES structure conforming to SRI requirements', () async {
      final signedXml = await SriSignatureService.signXmlXadesBes(
        xmlContent: sampleXml,
        p12FilePath: p12Path,
        p12Password: p12Pass,
      );

      expect(signedXml, isNotEmpty);
      expect(signedXml, contains('<ds:Signature'));
      expect(signedXml, contains('<ds:SignedInfo'));
      expect(signedXml, contains('<ds:SignatureValue'));
      expect(signedXml, contains('<ds:KeyInfo'));
      expect(signedXml, contains('<etsi:QualifyingProperties'));
      expect(signedXml, contains('<etsi:SignedProperties'));
      expect(signedXml, contains('<etsi:SigningTime>'));
      expect(signedXml, contains('<etsi:SigningCertificate>'));
      expect(signedXml, contains('</factura>'));

      // Validate signature with mathematical verifier
      final isValid = SriSignatureService.verifyXmlSignature(signedXml);
      expect(isValid, isTrue);
    });

    test('Detects unauthorized modifications and rejects altered XML (Tamper Detection)', () async {
      final signedXml = await SriSignatureService.signXmlXadesBes(
        xmlContent: sampleXml,
        p12FilePath: p12Path,
        p12Password: p12Pass,
      );

      // Alteración 1: Modificar el total de la factura
      final tamperedXmlTotal = signedXml.replaceFirst('<importeTotal>23.00</importeTotal>', '<importeTotal>99.00</importeTotal>');
      expect(
        () => SriSignatureService.verifyXmlSignature(tamperedXmlTotal),
        throwsA(isA<Exception>()),
      );

      // Alteración 2: Modificar el RUC
      final tamperedXmlRuc = signedXml.replaceFirst('1799999999001', '1700000000001');
      expect(
        () => SriSignatureService.verifyXmlSignature(tamperedXmlRuc),
        throwsA(isA<Exception>()),
      );
    });
  });
}
