import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contrato abstracto para impresoras de tickets (SOLID: ISP & OCP)
abstract interface class TicketPrinter {
  String get name;
  Future<bool> isConnected();
  Future<bool> printRawBytes(Uint8List bytes);
}

/// Impresora virtual para depuración y pruebas sin hardware físico
class VirtualDebugPrinter implements TicketPrinter {
  @override
  String get name => 'Virtual Debug Printer';

  @override
  Future<bool> isConnected() async => true;

  @override
  Future<bool> printRawBytes(Uint8List bytes) async {
    // En desarrollo/tests registramos que se generaron los bytes ESC/POS
    return true;
  }
}

/// Generador de comandos estándar ESC/POS para impresoras térmicas (80mm y 58mm)
class EscPosBuilder {
  final List<int> _bytes = [];

  Uint8List build() => Uint8List.fromList(_bytes);

  /// Inicializa la impresora (ESC @)
  EscPosBuilder initialize() {
    _bytes.addAll([0x1B, 0x40]);
    return this;
  }

  /// Alineación del texto (0: izquierda, 1: centro, 2: derecha)
  EscPosBuilder setAlignment(int align) {
    _bytes.addAll([0x1B, 0x61, align]);
    return this;
  }

  /// Texto en negrita
  EscPosBuilder setBold(bool bold) {
    _bytes.addAll([0x1B, 0x45, bold ? 1 : 0]);
    return this;
  }

  /// Agrega texto con salto de línea
  EscPosBuilder text(String text) {
    _bytes.addAll(text.codeUnits);
    _bytes.add(0x0A); // LF
    return this;
  }

  /// Línea divisoria
  EscPosBuilder divider([int length = 48]) {
    _bytes.addAll(List.filled(length, 0x2D)); // '-'
    _bytes.add(0x0A);
    return this;
  }

  /// Fila con dos columnas alineadas a izquierda y derecha
  EscPosBuilder twoColumns(String left, String right, [int width = 48]) {
    final int spaces = width - left.length - right.length;
    final String pad = spaces > 0 ? ' ' * spaces : ' ';
    return text('$left$pad$right');
  }

  /// Corte total de papel (GS V 0)
  EscPosBuilder cutPaper() {
    _bytes.addAll([0x1D, 0x56, 0x00]);
    return this;
  }
}

/// Proveedor Riverpod de la impresora activa
final ticketPrinterProvider = Provider<TicketPrinter>((ref) {
  return VirtualDebugPrinter();
});
