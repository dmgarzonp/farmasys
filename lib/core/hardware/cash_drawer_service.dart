import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ticket_printer_service.dart';

/// Interfaz segregada para apertura de gaveta portamonedas (SOLID: ISP)
abstract interface class CashDrawerKickable {
  Future<bool> openCashDrawer();
}

/// Implementación estándar que envía el pulso eléctrico pin RJ11 a través de la impresora
class EscPosCashDrawerService implements CashDrawerKickable {
  final TicketPrinter _printer;

  EscPosCashDrawerService(this._printer);

  // Comando ESC/POS estándar de apertura de gaveta: ESC p m t1 t2
  // m=0 (pin 2), t1=50ms, t2=500ms
  static final Uint8List _openDrawerCommand = Uint8List.fromList([0x1B, 0x70, 0x00, 0x19, 0xFA]);

  @override
  Future<bool> openCashDrawer() async {
    return _printer.printRawBytes(_openDrawerCommand);
  }
}

final cashDrawerServiceProvider = Provider<CashDrawerKickable>((ref) {
  final printer = ref.watch(ticketPrinterProvider);
  return EscPosCashDrawerService(printer);
});
