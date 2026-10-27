import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:intl/intl.dart';
import 'package:pkcs12_parser/pkcs12_parser.dart';
import 'package:pointycastle/export.dart';
import 'package:xml/xml.dart';
import 'xml_c14n.dart';

/// Información extraída y validada de un certificado digital PKCS#12 (.p12 / .pfx)
class SriCertificateInfo {
  final Map<String, String> subject;
  final Map<String, String> issuer;
  final String issuerDn;
  final String serialNumberHex;
  final String serialNumberDec;
  final DateTime notBefore;
  final DateTime notAfter;
  final bool isValid;
  final bool isExpired;
  final int daysUntilExpiration;
  final String commonName;
  final String? rucOrIdentifier;

  SriCertificateInfo({
    required this.subject,
    required this.issuer,
    required this.issuerDn,
    required this.serialNumberHex,
    required this.serialNumberDec,
    required this.notBefore,
    required this.notAfter,
    required this.isValid,
    required this.isExpired,
    required this.daysUntilExpiration,
    required this.commonName,
    this.rucOrIdentifier,
  });

  @override
  String toString() =>
      'SriCertificateInfo(CN: $commonName, RUC: $rucOrIdentifier, ValidoHasta: $notAfter, ExpiraEnDias: $daysUntilExpiration)';
}

/// Motor criptográfico nativo en Dart para la Firma Electrónica XAdES-BES
/// cumpliendo estrictamente con la Ficha Técnica v2.1.0 del SRI de Ecuador.
///
/// Soporta certificados de todas las entidades emisoras de Ecuador (BCE,
/// Security Data, UANATACA, ANFAC, Consejo de la Judicatura, etc.)
/// sin requerir binarios nativos externos (como OpenSSL o Java).
class SriSignatureService {
  /// Valida un archivo .p12 con su contraseña y extrae metadatos del certificado.
  static Future<SriCertificateInfo> validateP12File({
    required String p12FilePath,
    required String p12Password,
  }) async {
    final file = File(p12FilePath);
    if (!await file.exists()) {
      throw Exception('El archivo de firma .p12 no existe en la ruta: $p12FilePath');
    }

    try {
      final bytes = await file.readAsBytes();
      final pfx = Pkcs12.load(bytes, p12Password);
      final cert = pfx.certificate;

      if (pfx.privateKey is! RSAPrivateKey) {
        throw Exception(
          'El archivo contiene una clave privada incompatible (${pfx.privateKey.runtimeType}). Se requiere clave RSA.',
        );
      }

      final now = DateTime.now().toUtc();
      final isExpired = now.isAfter(cert.notAfter);
      final isValid = cert.isValidAt(now);
      final daysUntilExp = cert.notAfter.difference(now).inDays;

      final hexSerial = cert.serialNumber;
      final decSerial = BigInt.parse(hexSerial, radix: 16).toString();
      final issuerDn = formatIssuerDn(cert.issuer);

      final cn = cert.subject['CN'] ?? 'Desconocido';
      final ruc = cert.subject['SERIALNUMBER'] ?? cert.subject['serialNumber'];

      return SriCertificateInfo(
        subject: cert.subject,
        issuer: cert.issuer,
        issuerDn: issuerDn,
        serialNumberHex: hexSerial,
        serialNumberDec: decSerial,
        notBefore: cert.notBefore.toLocal(),
        notAfter: cert.notAfter.toLocal(),
        isValid: isValid,
        isExpired: isExpired,
        daysUntilExpiration: daysUntilExp,
        commonName: cn,
        rucOrIdentifier: ruc,
      );
    } on Pkcs12Exception catch (e) {
      throw Exception('Error al abrir la firma digital: Contraseña incorrecta o archivo .p12 corrupto ($e)');
    } catch (e) {
      throw Exception('Error al validar el certificado de firma: $e');
    }
  }

  /// Firma un documento XML en formato XAdES-BES (Enveloped) para el SRI.
  ///
  /// Pasos ejecutados:
  /// 1. Canonicalización C14N y SHA-1 Digest del comprobante original.
  /// 2. Construcción y digest de <etsi:SignedProperties> (con fecha y huella del cert).
  /// 3. Construcción y digest de <ds:KeyInfo> (con clave pública y certificado).
  /// 4. Construcción de <ds:SignedInfo> con las 3 referencias obligatorias.
  /// 5. Firma digital RSA-SHA1 de <ds:SignedInfo> con la clave privada del .p12.
  /// 6. Inyección del nodo <ds:Signature> dentro del elemento raíz del comprobante.
  static Future<String> signXmlXadesBes({
    required String xmlContent,
    required String p12FilePath,
    required String p12Password,
  }) async {
    final file = File(p12FilePath);
    if (!await file.exists()) {
      throw Exception('El archivo de firma .p12 no existe en la ruta: $p12FilePath');
    }

    final p12Bytes = await file.readAsBytes();
    final Pkcs12 pfx;
    try {
      pfx = Pkcs12.load(p12Bytes, p12Password);
    } catch (e) {
      throw Exception('No se pudo abrir el archivo de firma .p12: Verifique la contraseña ($e)');
    }

    final cert = pfx.certificate;
    if (pfx.privateKey is! RSAPrivateKey) {
      throw Exception('La clave privada del archivo no es de tipo RSA.');
    }
    final privKey = pfx.privateKey as RSAPrivateKey;
    final pubKey = pfx.publicKey as RSAPublicKey;

    // Metadatos criptográficos del certificado
    final certDer = cert.der;
    final certBase64 = base64.encode(certDer);
    final modulusBase64 = base64.encode(_bigIntToUnsignedBytes(pubKey.modulus!));
    final exponentBase64 = base64.encode(_bigIntToUnsignedBytes(pubKey.exponent!));
    final certDigestBase64 = base64.encode(crypto.sha1.convert(certDer).bytes);

    final issuerDn = formatIssuerDn(cert.issuer);
    final serialNumberDec = BigInt.parse(cert.serialNumber, radix: 16).toString();

    // Fecha y hora local con formato ISO 8601 y zona horaria (ej: 2026-10-26T21:30:00-05:00)
    final now = DateTime.now();
    final timeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    final offsetHours = now.timeZoneOffset.inHours;
    final offsetMinutes = now.timeZoneOffset.inMinutes.remainder(60).abs();
    final signStr = offsetHours >= 0 ? '+' : '-';
    final tzStr = '$signStr${offsetHours.abs().toString().padLeft(2, '0')}:${offsetMinutes.toString().padLeft(2, '0')}';
    final signingTime = '${timeFormat.format(now)}$tzStr';

    // Parsear documento original
    final XmlDocument originalDoc;
    try {
      originalDoc = XmlDocument.parse(xmlContent);
    } catch (e) {
      throw Exception('El contenido XML del comprobante tiene errores de sintaxis: $e');
    }

    final rootElement = originalDoc.rootElement;
    final rootTagName = rootElement.name.local;

    // Asegurar que el id="comprobante" esté presente en el nodo raíz
    if (rootElement.getAttribute('id') != 'comprobante') {
      rootElement.setAttribute('id', 'comprobante');
    }

    // 1. Digest del documento original (Transform: Enveloped Signature)
    final canonicalComprobante = XmlC14n.canonicalize(rootElement);
    final comprobanteDigest = base64.encode(
      crypto.sha1.convert(utf8.encode(canonicalComprobante)).bytes,
    );

    // Identificadores únicos para este comprobante
    final randomDigits = _generateRandomDigits(6);
    final signatureId = 'Signature-$randomDigits';
    final signedInfoId = 'Signature-SignedInfo-$randomDigits';
    final signedPropertiesId = 'SignedPropertiesID-$randomDigits';
    final certificateId = 'Certificate-$randomDigits';
    final referenceId = 'Reference-ID-$randomDigits';

    // 2. Construcción de SignedProperties
    final signedPropertiesXml =
        '<etsi:SignedProperties xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:etsi="http://uri.etsi.org/01903/v1.3.2#" Id="$signedPropertiesId">'
        '<etsi:SignedSignatureProperties>'
        '<etsi:SigningTime>$signingTime</etsi:SigningTime>'
        '<etsi:SigningCertificate>'
        '<etsi:Cert>'
        '<etsi:CertDigest>'
        '<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>'
        '<ds:DigestValue>$certDigestBase64</ds:DigestValue>'
        '</etsi:CertDigest>'
        '<etsi:IssuerSerial>'
        '<ds:X509IssuerName>$issuerDn</ds:X509IssuerName>'
        '<ds:X509SerialNumber>$serialNumberDec</ds:X509SerialNumber>'
        '</etsi:IssuerSerial>'
        '</etsi:Cert>'
        '</etsi:SigningCertificate>'
        '</etsi:SignedSignatureProperties>'
        '<etsi:SignedDataObjectProperties>'
        '<etsi:DataObjectFormat ObjectReference="#$referenceId">'
        '<etsi:Description>contenido comprobante</etsi:Description>'
        '<etsi:MimeType>text/xml</etsi:MimeType>'
        '</etsi:DataObjectFormat>'
        '</etsi:SignedDataObjectProperties>'
        '</etsi:SignedProperties>';

    final canonicalSignedProps = XmlC14n.canonicalize(
      XmlDocument.parse(signedPropertiesXml).rootElement,
    );
    final signedPropertiesDigest = base64.encode(
      crypto.sha1.convert(utf8.encode(canonicalSignedProps)).bytes,
    );

    // 3. Construcción de KeyInfo
    final keyInfoXml =
        '<ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#" Id="$certificateId">'
        '<ds:X509Data>'
        '<ds:X509Certificate>$certBase64</ds:X509Certificate>'
        '</ds:X509Data>'
        '<ds:KeyValue>'
        '<ds:RSAKeyValue>'
        '<ds:Modulus>$modulusBase64</ds:Modulus>'
        '<ds:Exponent>$exponentBase64</ds:Exponent>'
        '</ds:RSAKeyValue>'
        '</ds:KeyValue>'
        '</ds:KeyInfo>';

    final canonicalKeyInfo = XmlC14n.canonicalize(
      XmlDocument.parse(keyInfoXml).rootElement,
    );
    final certificateDigest = base64.encode(
      crypto.sha1.convert(utf8.encode(canonicalKeyInfo)).bytes,
    );

    // 4. Construcción de SignedInfo con las 3 Referencias
    final signedInfoXml =
        '<ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#" Id="$signedInfoId">'
        '<ds:CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></ds:CanonicalizationMethod>'
        '<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></ds:SignatureMethod>'
        '<ds:Reference Id="$signedPropertiesId" Type="http://uri.etsi.org/01903#SignedProperties" URI="#$signedPropertiesId">'
        '<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>'
        '<ds:DigestValue>$signedPropertiesDigest</ds:DigestValue>'
        '</ds:Reference>'
        '<ds:Reference URI="#$certificateId">'
        '<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>'
        '<ds:DigestValue>$certificateDigest</ds:DigestValue>'
        '</ds:Reference>'
        '<ds:Reference Id="$referenceId" URI="#comprobante">'
        '<ds:Transforms>'
        '<ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></ds:Transform>'
        '</ds:Transforms>'
        '<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></ds:DigestMethod>'
        '<ds:DigestValue>$comprobanteDigest</ds:DigestValue>'
        '</ds:Reference>'
        '</ds:SignedInfo>';

    final canonicalSignedInfo = XmlC14n.canonicalize(
      XmlDocument.parse(signedInfoXml).rootElement,
    );

    // 5. Firma Digital RSA-SHA1 de SignedInfo
    final signer = Signer('SHA-1/RSA');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privKey));
    final signatureObj =
        signer.generateSignature(utf8.encode(canonicalSignedInfo)) as RSASignature;
    final signatureValueBase64 = base64.encode(signatureObj.bytes);

    // 6. Ensamblado completo de Signature
    final signatureBlock =
        '<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#" Id="$signatureId">'
        '$canonicalSignedInfo'
        '<ds:SignatureValue Id="SignatureValue-$randomDigits">$signatureValueBase64</ds:SignatureValue>'
        '$canonicalKeyInfo'
        '<ds:Object Id="Signature-Object-$randomDigits">'
        '<etsi:QualifyingProperties xmlns:etsi="http://uri.etsi.org/01903/v1.3.2#" Target="#$signatureId">'
        '$canonicalSignedProps'
        '</etsi:QualifyingProperties>'
        '</ds:Object>'
        '</ds:Signature>';

    // Inyectar el bloque de firma al final del comprobante, justo antes de su cierre
    final closingTag = '</$rootTagName>';
    final lastIndex = xmlContent.lastIndexOf(closingTag);
    if (lastIndex == -1) {
      throw Exception('No se encontró la etiqueta de cierre $closingTag en el XML.');
    }

    final signedXml = '${xmlContent.substring(0, lastIndex)}$signatureBlock$closingTag';
    return signedXml;
  }

  /// Verifica la validez matemática y estructural de un comprobante XML firmado con XAdES-BES.
  static bool verifyXmlSignature(String signedXml) {
    final doc = XmlDocument.parse(signedXml);
    final sigNode = doc.findAllElements('ds:Signature').firstOrNull;
    if (sigNode == null) {
      throw Exception('El documento XML no contiene un nodo de firma <ds:Signature>.');
    }

    // 1. Obtener certificado y clave pública
    final certNode = sigNode.findAllElements('ds:X509Certificate').firstOrNull;
    if (certNode == null) {
      throw Exception('No se encontró el nodo <ds:X509Certificate> en la firma.');
    }
    final certBytes = base64.decode(certNode.innerText.replaceAll(RegExp(r'\s+'), ''));
    final certDer = X509CertificateDer(certBytes);
    final pubKey = certDer.publicKey as RSAPublicKey;

    // 2. Extraer SignatureValue
    final sigValNode = sigNode.findAllElements('ds:SignatureValue').firstOrNull;
    if (sigValNode == null) {
      throw Exception('No se encontró el nodo <ds:SignatureValue>.');
    }
    final sigBytes = base64.decode(sigValNode.innerText.replaceAll(RegExp(r'\s+'), ''));

    // 3. Verificar firma de SignedInfo
    final signedInfoNode = sigNode.findAllElements('ds:SignedInfo').first;
    final canonicalSignedInfo = XmlC14n.canonicalize(signedInfoNode);

    final verifier = Signer('SHA-1/RSA');
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(pubKey));
    final isSigValid = verifier.verifySignature(
      utf8.encode(canonicalSignedInfo),
      RSASignature(sigBytes),
    );
    if (!isSigValid) {
      throw Exception('La firma digital RSA-SHA1 de SignedInfo no coincide con la clave pública.');
    }

    // 4. Verificar Referencias
    final references = signedInfoNode.findAllElements('ds:Reference');
    for (final ref in references) {
      final uri = ref.getAttribute('URI') ?? '';
      final expectedDigest = ref.findElements('ds:DigestValue').first.innerText.trim();

      if (uri.startsWith('#SignedPropertiesID')) {
        final spNode = sigNode.findAllElements('etsi:SignedProperties').first;
        final canonicalSp = XmlC14n.canonicalize(spNode);
        final actualDigest = base64.encode(crypto.sha1.convert(utf8.encode(canonicalSp)).bytes);
        if (actualDigest != expectedDigest) {
          throw Exception('Digest mismatch en SignedProperties ($actualDigest != $expectedDigest)');
        }
      } else if (uri.startsWith('#Certificate')) {
        final kiNode = sigNode.findAllElements('ds:KeyInfo').first;
        final canonicalKi = XmlC14n.canonicalize(kiNode);
        final actualDigest = base64.encode(crypto.sha1.convert(utf8.encode(canonicalKi)).bytes);
        if (actualDigest != expectedDigest) {
          throw Exception('Digest mismatch en KeyInfo/Certificate ($actualDigest != $expectedDigest)');
        }
      } else if (uri == '#comprobante') {
        // Clonar documento y remover <ds:Signature>
        final docCopy = XmlDocument.parse(signedXml);
        final sigToRemove = docCopy.findAllElements('ds:Signature').first;
        sigToRemove.parent?.children.remove(sigToRemove);
        final canonicalRoot = XmlC14n.canonicalize(docCopy.rootElement);
        final actualDigest = base64.encode(crypto.sha1.convert(utf8.encode(canonicalRoot)).bytes);
        if (actualDigest != expectedDigest) {
          throw Exception('Digest mismatch en el cuerpo del comprobante ($actualDigest != $expectedDigest)');
        }
      }
    }

    return true;
  }

  /// Formatea los componentes del Issuer a formato estándar RFC 2253 (CN, OU, O, C)
  static String formatIssuerDn(Map<String, String> issuer) {
    final orderedKeys = ['CN', 'OU', 'O', 'C', 'L', 'ST', 'SERIALNUMBER'];
    final parts = <String>[];
    for (final k in orderedKeys) {
      if (issuer.containsKey(k)) {
        parts.add('$k=${issuer[k]}');
      }
    }
    for (final entry in issuer.entries) {
      if (!orderedKeys.contains(entry.key)) {
        parts.add('${entry.key}=${entry.value}');
      }
    }
    return parts.join(',');
  }

  static Uint8List _bigIntToUnsignedBytes(BigInt number) {
    var hex = number.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  static String _generateRandomDigits(int length) {
    final rnd = Random();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(rnd.nextInt(10));
    }
    return buffer.toString();
  }
}
