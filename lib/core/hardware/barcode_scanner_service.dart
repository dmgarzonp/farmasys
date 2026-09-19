import 'dart:async';
import 'package:flutter/services.dart';

/// Detector inteligente de código de barras para lectores USB HID (emuladores de teclado)
/// Diferencia la entrada ultra-rápida de un escáner láser (< 35ms por carácter) de la escritura humana.
class BarcodeScannerService {
  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeystrokeTime;
  final Duration _maxKeystrokeThreshold = const Duration(milliseconds: 45);

  final StreamController<String> _scanController = StreamController<String>.broadcast();
  Stream<String> get onScan => _scanController.stream;

  /// Procesa eventos de teclado a nivel de ventana global
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final String? char = event.character;
    final DateTime now = DateTime.now();

    // Si pasa demasiado tiempo entre caracteres, es un usuario tecleando
    if (_lastKeystrokeTime != null && now.difference(_lastKeystrokeTime!) > _maxKeystrokeThreshold) {
      _buffer.clear();
    }
    _lastKeystrokeTime = now;

    // Los escáneres finalizan típicamente con Enter
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final String code = _buffer.toString().trim();
      _buffer.clear();
      if (code.length >= 3) {
        _scanController.add(code);
        return true; // Evento consumido
      }
      return false;
    }

    if (char != null && char.isNotEmpty) {
      _buffer.write(char);
    }

    return false;
  }

  void dispose() {
    _scanController.close();
  }
}
