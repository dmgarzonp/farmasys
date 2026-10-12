import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class BackupService {
  static const String _dbFileName = 'farmsys_demo_db.sqlite';
  static const String _backupDirName = 'FarmSys_Backups';

  /// Obtiene el archivo actual de la base de datos de la aplicación.
  Future<File> getDatabaseFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbFileName);
    return File(dbPath);
  }

  /// Exporta una copia de la base de datos a un directorio específico (ej. un USB seleccionado).
  Future<String> exportToPath(String destinationDirectory) async {
    final dbFile = await getDatabaseFile();
    if (!await dbFile.exists()) {
      throw Exception('El archivo de la base de datos no existe.');
    }

    final dateStr = DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now());
    final destFileName = 'farmsys_backup_$dateStr.sqlite';
    final destPath = p.join(destinationDirectory, destFileName);

    await dbFile.copy(destPath);
    return destPath;
  }

  /// Crea un respaldo automático local en Documentos/FarmSys_Backups
  /// y elimina respaldos con más de 7 días de antigüedad.
  Future<void> autoLocalBackup() async {
    try {
      final dbFile = await getDatabaseFile();
      if (!await dbFile.exists()) return; // No hay DB que respaldar

      // Obtener la carpeta principal de Documentos del usuario
      final docsDir = await getApplicationDocumentsDirectory();
      // En Desktop, getApplicationDocumentsDirectory() normalmente devuelve "Documentos".
      final backupDirPath = p.join(docsDir.path, _backupDirName);
      final backupDir = Directory(backupDirPath);

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Copiar el archivo actual
      final dateStr = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final destPath = p.join(backupDir.path, 'backup_$dateStr.sqlite');
      await dbFile.copy(destPath);

      // Limpiar respaldos viejos (retención de 7 días)
      await _cleanOldBackups(backupDir);
    } catch (e) {
      // Registrar silenciosamente (no detener el cierre de la app)
      print('Error al crear respaldo automático local: $e');
    }
  }

  Future<void> _cleanOldBackups(Directory backupDir) async {
    final files = backupDir.listSync().whereType<File>().toList();
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    for (var file in files) {
      if (file.path.endsWith('.sqlite')) {
        final stat = await file.stat();
        if (stat.modified.isBefore(sevenDaysAgo)) {
          await file.delete();
        }
      }
    }
  }

  /// Restaura la base de datos desde un archivo de respaldo.
  Future<void> restoreDatabase(String backupFilePath) async {
    final backupFile = File(backupFilePath);
    if (!await backupFile.exists()) {
      throw Exception('El archivo de respaldo no existe o no se puede leer.');
    }

    final dbFile = await getDatabaseFile();
    
    // Aquí idealmente la conexión a drift debería estar cerrada.
    // Como el usuario va a reiniciar después de esto, sobrescribimos directamente.
    await backupFile.copy(dbFile.path);
  }
}

final backupService = BackupService();
