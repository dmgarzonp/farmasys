import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resuelve el directorio seguro y encapsulado para almacenar la base de datos de FarmSys.
///
/// En Windows: `%APPDATA%\FarmSys\data\` (Oculta, protegida contra borrado accidental de usuarios)
/// En Linux: `~/.local/share/farmsys/data/` (Estándar XDG)
/// En macOS/Otros: getApplicationSupportDirectory() / 'FarmSys' / 'data'
Future<Directory> getFarmSysDataDirectory() async {
  String dirPath;

  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.trim().isNotEmpty) {
      dirPath = p.join(appData.trim(), 'FarmSys', 'data');
    } else {
      final base = await getApplicationSupportDirectory();
      dirPath = p.join(base.path, 'FarmSys', 'data');
    }
  } else if (Platform.isLinux) {
    final xdgData = Platform.environment['XDG_DATA_HOME'];
    if (xdgData != null && xdgData.trim().isNotEmpty) {
      dirPath = p.join(xdgData.trim(), 'farmsys', 'data');
    } else {
      final home = Platform.environment['HOME'];
      if (home != null && home.trim().isNotEmpty) {
        dirPath = p.join(home.trim(), '.local', 'share', 'farmsys', 'data');
      } else {
        final base = await getApplicationSupportDirectory();
        dirPath = p.join(base.path, 'farmsys', 'data');
      }
    }
  } else {
    final base = await getApplicationSupportDirectory();
    dirPath = p.join(base.path, 'farmsys', 'data');
  }

  final dir = Directory(dirPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Obtiene la ruta física del archivo oficial `farmsys.db`.
Future<String> resolveDefaultDatabaseFilePath() async {
  final dataDir = await getFarmSysDataDirectory();
  return p.join(dataDir.path, 'farmsys.db');
}

/// Abre la carpeta que contiene la base de datos en el explorador de archivos nativo del sistema operativo.
/// 
/// En Windows: Abre `explorer.exe` directamente en la carpeta (incluso si está oculta).
/// En Linux: Ejecuta `xdg-open`.
/// En macOS: Ejecuta `open`.
Future<void> openFolderInExplorer(String path) async {
  try {
    final folder = (await FileSystemEntity.isDirectory(path))
        ? path
        : p.dirname(path);

    if (Platform.isWindows) {
      await Process.run('explorer.exe', [folder]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [folder]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [folder]);
    }
  } catch (_) {
    // Si falla el comando de shell nativo, no bloqueamos la app
  }
}
