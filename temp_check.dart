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
  
  try {
    final result = db.select('SELECT * FROM usuarios_table');
    print('Usuarios:');
    for (final row in result) {
      print(row);
    }
  } catch (e) {
    print('Error: $e');
  }
  
  try {
    final result = db.select('PRAGMA user_version');
    print('Schema version: $result');
  } catch (e) {
    print('Error: $e');
  }
  
  db.dispose();
}
