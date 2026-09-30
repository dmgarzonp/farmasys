import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final path = '.dart_tool/sqflite_common_ffi/databases/farmsys_demo_db.sqlite';
  final dbPath = File(path).existsSync() ? path : 'farmsys_demo_db.sqlite'; 
  
  final linuxPath = '${Platform.environment['HOME']}/Documents/farmsys_demo_db.sqlite';
  
  String actualPath = '';
  if (File(path).existsSync()) actualPath = path;
  else if (File(dbPath).existsSync()) actualPath = dbPath;
  else if (File(linuxPath).existsSync()) actualPath = linuxPath;
  else {
    print('Database not found.');
    return;
  }
  
  print('Using db at $actualPath');
  final db = sqlite3.open(actualPath);
  
  print('\n--- PRODUCTOS SIN PRECIO DE VENTA (PVP = 0) ---');
  final result = db.select('''
    SELECT p.id, p.nombreComercial, pr.nombreDescriptivo, pr.precioVentaCaja 
    FROM productos p
    JOIN presentaciones pr ON p.id = pr.productoId
    WHERE pr.precioVentaCaja = 0 OR pr.precioVentaCaja IS NULL
  ''');
  
  if (result.isEmpty) {
    print('Todos los productos tienen precio de venta.');
  } else {
    for (final row in result) {
      print('ID: ${row['id']} | Producto: ${row['nombreComercial']} | Presentación: ${row['nombreDescriptivo']} | PVP: ${row['precioVentaCaja']}');
    }
  }
  
  db.dispose();
}
