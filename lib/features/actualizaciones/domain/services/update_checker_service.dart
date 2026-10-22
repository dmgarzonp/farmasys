import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/app_update_info.dart';

/// Servicio responsable de comprobar, descargar e iniciar actualizaciones de FarmSys
class UpdateCheckerService {
  static const String defaultOwner = 'dmgarzonp';
  static const String defaultRepo = 'farmasys';
  static const String lastCheckPrefKey = 'settings_last_update_check';

  final String owner;
  final String repo;

  UpdateCheckerService({
    this.owner = defaultOwner,
    this.repo = defaultRepo,
  });

  /// Compara si remoteVersion es estrictamente mayor que currentVersion (SemVer 3 partes)
  static bool isVersionNewer(String current, String remote) {
    String clean(String v) {
      var s = v.trim();
      if (s.toLowerCase().startsWith('v')) {
        s = s.substring(1);
      }
      if (s.contains('+')) {
        s = s.split('+').first;
      }
      if (s.contains('-')) {
        s = s.split('-').first;
      }
      return s;
    }

    final cClean = clean(current);
    final rClean = clean(remote);

    final cParts = cClean
        .split('.')
        .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final rParts = rClean
        .split('.')
        .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();

    while (cParts.length < 3) {
      cParts.add(0);
    }
    while (rParts.length < 3) {
      rParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (rParts[i] > cParts[i]) return true;
      if (rParts[i] < cParts[i]) return false;
    }
    return false;
  }

  /// Parsea la respuesta JSON de GitHub Releases y construye el modelo de actualización
  AppUpdateInfo parseReleaseJson(
    Map<String, dynamic> data, {
    String? currentVersionOverride,
    String? platformOverride,
  }) {
    final currentVer = currentVersionOverride ?? AppConstants.appVersion;
    final tagName = (data['tag_name'] as String? ?? '').replaceFirst('v', '').trim();
    final releaseName = data['name'] as String? ?? 'FarmSys v$tagName';
    final body = data['body'] as String? ?? '';
    final publishedAtStr = data['published_at'] as String?;
    final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

    final assets = (data['assets'] as List<dynamic>? ?? []);
    String? downloadUrl;
    String? fileName;
    int sizeBytes = 0;

    final isWin = platformOverride != null ? platformOverride == 'windows' : Platform.isWindows;
    final isLinux = platformOverride != null ? platformOverride == 'linux' : Platform.isLinux;

    if (isWin) {
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.exe')) {
          downloadUrl = asset['browser_download_url'] as String?;
          fileName = asset['name'] as String?;
          sizeBytes = asset['size'] as int? ?? 0;
          break;
        }
      }
    } else if (isLinux) {
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.deb')) {
          downloadUrl = asset['browser_download_url'] as String?;
          fileName = asset['name'] as String?;
          sizeBytes = asset['size'] as int? ?? 0;
          break;
        }
      }
    }

    final hasNewer = isVersionNewer(currentVer, tagName);

    return AppUpdateInfo(
      hasUpdate: hasNewer,
      currentVersion: currentVer,
      latestVersion: tagName,
      releaseName: releaseName,
      releaseNotes: body,
      publishedAt: publishedAt,
      downloadUrl: downloadUrl,
      fileName: fileName,
      fileSizeBytes: sizeBytes,
    );
  }

  /// Consulta la API pública de GitHub Releases para verificar si hay una nueva versión
  Future<AppUpdateInfo?> checkForUpdates({bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!force) {
        final lastCheckStr = prefs.getString(lastCheckPrefKey);
        if (lastCheckStr != null) {
          final lastCheck = DateTime.tryParse(lastCheckStr);
          if (lastCheck != null &&
              DateTime.now().difference(lastCheck).inHours < 4) {
            // Ya se verificó en las últimas 4 horas, evitar exceso de peticiones
            return null;
          }
        }
      }

      await prefs.setString(lastCheckPrefKey, DateTime.now().toIso8601String());

      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 12);

      final request = await client.getUrl(url);
      request.headers.set('User-Agent', 'FarmSys-Desktop-App');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close();
      if (response.statusCode != 200) {
        return null;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody) as Map<String, dynamic>;

      return parseReleaseJson(data);
    } catch (e) {
      debugPrint('UpdateCheckerService: No se pudo consultar actualizaciones ($e)');
      return null;
    }
  }

  /// Descarga el instalador con seguimiento de progreso en vivo
  Future<File> downloadInstaller({
    required String downloadUrl,
    required String fileName,
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(downloadUrl));
    request.headers.set('User-Agent', 'FarmSys-Desktop-App');
    request.followRedirects = true;
    request.maxRedirects = 5;

    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('Error al descargar instalador: HTTP ${response.statusCode}');
    }

    final totalBytes = response.contentLength;
    int receivedBytes = 0;

    final tempDir = await getTemporaryDirectory();
    final targetFile = File(p.join(tempDir.path, fileName));
    final sink = targetFile.openWrite();

    try {
      await response.listen((List<int> chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes, receivedBytes, totalBytes);
        }
      }).asFuture<void>();
    } finally {
      await sink.flush();
      await sink.close();
    }

    return targetFile;
  }

  /// Ejecuta el instalador descargado en segundo plano y prepara el cierre de FarmSys
  Future<void> launchInstallerAndExit(File installerFile) async {
    if (Platform.isWindows) {
      // En Windows inicia el instalador .exe asistido y cierra la aplicación
      await Process.start(
        installerFile.path,
        [],
        mode: ProcessStartMode.detached,
      );
      exit(0);
    } else if (Platform.isLinux) {
      // En Linux, ejecutar la instalación directa mediante pkexec (Polkit GUI)
      // para evitar las limitaciones y bloqueos del Centro de Software de Ubuntu.
      final scriptFile = File(p.join(Directory.systemTemp.path, 'farmsys_upgrade.sh'));
      await scriptFile.writeAsString('''#!/usr/bin/env bash
DEB_PATH="${installerFile.path}"

if command -v pkexec >/dev/null 2>&1; then
    pkexec dpkg -i "\$DEB_PATH"
    EXIT_CODE=\$?
else
    EXIT_CODE=1
fi

if [ \$EXIT_CODE -eq 0 ]; then
    nohup /usr/bin/farmsys >/dev/null 2>&1 &
    exit 0
else
    exit \$EXIT_CODE
fi
''');
      await Process.run('chmod', ['+x', scriptFile.path]);

      final result = await Process.run(scriptFile.path, []);
      if (result.exitCode == 0) {
        exit(0);
      } else {
        throw Exception(
          'La actualización requiere permisos de superusuario. '
          'Si cancelaste la solicitud, puedes reintentar o instalar manualmente.',
        );
      }
    }
  }
}
