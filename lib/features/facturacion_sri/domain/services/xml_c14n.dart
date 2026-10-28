import 'package:xml/xml.dart';

/// Implementación de Canonical XML 1.0 (Inclusive C14N)
/// Recomendación oficial de la W3C (http://www.w3.org/TR/2001/REC-xml-c14n-20010315)
/// Requerida por la Ficha Técnica del SRI de Ecuador para firmas electrónicas XAdES-BES.
class XmlC14n {
  /// Canonicaliza un nodo XML ([XmlDocument], [XmlElement] o fragmento).
  ///
  /// Si [inheritedNamespaces] es provisto o si se omite pero el elemento
  /// tiene ancestros en un árbol, se procesan los espacios de nombres en alcance.
  static String canonicalize(
    XmlNode node, {
    Map<String, String>? inheritedNamespaces,
  }) {
    final buffer = StringBuffer();
    final inScope = inheritedNamespaces ?? _extractInScopeNamespaces(node);
    _canonicalizeNode(node, buffer, inScope, isRootOfSubset: true);
    return buffer.toString();
  }

  static Map<String, String> _extractInScopeNamespaces(XmlNode node) {
    final inScope = <String, String>{};
    if (node is! XmlElement) return inScope;

    final ancestors = <XmlElement>[];
    var current = node.parentElement;
    while (current != null) {
      ancestors.add(current);
      current = current.parentElement;
    }

    // De ancestro más antiguo al padre inmediato
    for (final ancestor in ancestors.reversed) {
      for (final attr in ancestor.attributes) {
        if (attr.name.prefix == 'xmlns') {
          inScope[attr.name.local] = attr.value;
        } else if (attr.name.qualified == 'xmlns') {
          inScope[''] = attr.value;
        }
      }
    }
    return inScope;
  }

  static void _canonicalizeNode(
    XmlNode node,
    StringBuffer buffer,
    Map<String, String> activeNamespaces, {
    bool isRootOfSubset = false,
  }) {
    if (node is XmlDocument) {
      final root = node.rootElement;
      _canonicalizeNode(root, buffer, activeNamespaces, isRootOfSubset: true);
    } else if (node is XmlElement) {
      final elem = node;
      buffer.write('<');
      buffer.write(elem.name.qualified);

      // Espacios de nombres declarados en este elemento
      final declaredNamespaces = <String, String>{};
      for (final attr in elem.attributes) {
        if (attr.name.prefix == 'xmlns') {
          declaredNamespaces[attr.name.local] = attr.value;
        } else if (attr.name.qualified == 'xmlns') {
          declaredNamespaces[''] = attr.value;
        }
      }

      final toRenderNamespaces = <String, String>{};
      final newActiveNamespaces = Map<String, String>.from(activeNamespaces);

      if (isRootOfSubset) {
        // En la raíz del subconjunto se emiten los namespaces heredados
        for (final entry in activeNamespaces.entries) {
          toRenderNamespaces[entry.key] = entry.value;
        }
      }

      for (final entry in declaredNamespaces.entries) {
        if (activeNamespaces[entry.key] != entry.value) {
          toRenderNamespaces[entry.key] = entry.value;
          newActiveNamespaces[entry.key] = entry.value;
        }
      }

      // Ordenar namespaces: 'xmlns' por defecto primero, luego alfabéticamente por prefijo
      final sortedPrefixes = toRenderNamespaces.keys.toList()
        ..sort((a, b) {
          if (a.isEmpty) return -1;
          if (b.isEmpty) return 1;
          return a.compareTo(b);
        });

      for (final prefix in sortedPrefixes) {
        final uri = toRenderNamespaces[prefix]!;
        if (prefix.isEmpty) {
          buffer.write(' xmlns="');
        } else {
          buffer.write(' xmlns:$prefix="');
        }
        buffer.write(_escapeAttribute(uri));
        buffer.write('"');
      }

      // Atributos regulares (no xmlns)
      final regularAttrs = elem.attributes
          .where((a) => a.name.prefix != 'xmlns' && a.name.qualified != 'xmlns')
          .toList();

      // Ordenar atributos: no prefijados primero por nombre, luego prefijados por URI + localName
      regularAttrs.sort((a, b) {
        final aHasPrefix = a.name.prefix != null;
        final bHasPrefix = b.name.prefix != null;
        if (!aHasPrefix && !bHasPrefix) {
          return a.name.local.compareTo(b.name.local);
        }
        if (!aHasPrefix && bHasPrefix) return -1;
        if (aHasPrefix && !bHasPrefix) return 1;
        final uriCmp = (a.name.namespaceUri ?? '').compareTo(b.name.namespaceUri ?? '');
        if (uriCmp != 0) return uriCmp;
        return a.name.local.compareTo(b.name.local);
      });

      for (final attr in regularAttrs) {
        buffer.write(' ${attr.name.qualified}="');
        buffer.write(_escapeAttribute(attr.value));
        buffer.write('"');
      }

      buffer.write('>');

      // Procesar hijos en orden de documento
      for (final child in elem.children) {
        _canonicalizeNode(child, buffer, newActiveNamespaces, isRootOfSubset: false);
      }

      buffer.write('</');
      buffer.write(elem.name.qualified);
      buffer.write('>');
    } else if (node is XmlText) {
      buffer.write(_escapeText(node.value));
    } else if (node is XmlCDATA) {
      buffer.write(_escapeText(node.value));
    }
    // Comentarios y Processing Instructions se omiten en C14N estándar sin comentarios
  }

  static String _escapeAttribute(String val) {
    return val
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('"', '&quot;')
        .replaceAll('\t', '&#x9;')
        .replaceAll('\n', '&#xA;')
        .replaceAll('\r', '&#xD;');
  }

  static String _escapeText(String val) {
    return val
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\r', '&#xD;');
  }
}

