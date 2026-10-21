import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/features/actualizaciones/domain/entities/app_update_info.dart';
import 'package:farmsys/features/actualizaciones/domain/services/update_checker_service.dart';

void main() {
  group('UpdateCheckerService - Comparación SemVer (isVersionNewer)', () {
    test('Detecta correctamente versiones menores más nuevas (patch)', () {
      expect(UpdateCheckerService.isVersionNewer('1.0.0', '1.0.1'), isTrue);
      expect(UpdateCheckerService.isVersionNewer('1.0.0', 'v1.0.1'), isTrue);
    });

    test('Detecta versiones intermedias y mayores (minor y major)', () {
      expect(UpdateCheckerService.isVersionNewer('1.0.0', '1.1.0'), isTrue);
      expect(UpdateCheckerService.isVersionNewer('1.0.0', '2.0.0'), isTrue);
      expect(UpdateCheckerService.isVersionNewer('1.9.9', '2.0.0'), isTrue);
    });

    test('Retorna false si la versión remota es igual o inferior', () {
      expect(UpdateCheckerService.isVersionNewer('1.0.0', '1.0.0'), isFalse);
      expect(UpdateCheckerService.isVersionNewer('1.0.1', '1.0.0'), isFalse);
      expect(UpdateCheckerService.isVersionNewer('2.0.0', '1.9.9'), isFalse);
    });

    test('Maneja sufijos o prefijos alfanuméricos como "v" o "+build"', () {
      expect(UpdateCheckerService.isVersionNewer('1.0.0+1', 'v1.0.1'), isTrue);
      expect(UpdateCheckerService.isVersionNewer('v1.0.0', '1.0.0'), isFalse);
    });

    test('Rellena adecuadamente versiones incompletas con ceros', () {
      expect(UpdateCheckerService.isVersionNewer('1.0', '1.0.1'), isTrue);
      expect(UpdateCheckerService.isVersionNewer('1.0.1', '1.0'), isFalse);
    });
  });

  group('UpdateCheckerService - Parseo de GitHub Releases JSON', () {
    final mockReleaseJson = {
      'tag_name': 'v1.0.1',
      'name': 'FarmSys v1.0.1 - Mejoras y SRI',
      'body': '- Corrección de decimales en facturación\n- Nuevos reportes FEFO',
      'published_at': '2026-10-25T14:30:00Z',
      'assets': [
        {
          'name': 'FarmSys_Setup_v1.0.1.exe',
          'browser_download_url': 'https://github.com/dmgarzonp/farmasys/releases/download/v1.0.1/FarmSys_Setup_v1.0.1.exe',
          'size': 16357785, // ~15.6 MB
        },
        {
          'name': 'farmsys_1.0.1_amd64.deb',
          'browser_download_url': 'https://github.com/dmgarzonp/farmasys/releases/download/v1.0.1/farmsys_1.0.1_amd64.deb',
          'size': 13841203, // ~13.2 MB
        },
      ],
    };

    test('Parsea release para Windows detectando el instalador .exe', () {
      final service = UpdateCheckerService();
      final info = service.parseReleaseJson(
        mockReleaseJson,
        currentVersionOverride: '1.0.0',
        platformOverride: 'windows',
      );

      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, '1.0.1');
      expect(info.currentVersion, '1.0.0');
      expect(info.releaseName, 'FarmSys v1.0.1 - Mejoras y SRI');
      expect(info.fileName, 'FarmSys_Setup_v1.0.1.exe');
      expect(info.downloadUrl, contains('FarmSys_Setup_v1.0.1.exe'));
      expect(info.formattedFileSize, '15.6 MB');
      expect(info.formattedDate, '25/10/2026');
      expect(info.releaseNotes, contains('Corrección de decimales'));
    });

    test('Parsea release para Linux detectando el paquete .deb', () {
      final service = UpdateCheckerService();
      final info = service.parseReleaseJson(
        mockReleaseJson,
        currentVersionOverride: '1.0.0',
        platformOverride: 'linux',
      );

      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, '1.0.1');
      expect(info.fileName, 'farmsys_1.0.1_amd64.deb');
      expect(info.downloadUrl, contains('farmsys_1.0.1_amd64.deb'));
      expect(info.formattedFileSize, '13.2 MB');
    });

    test('Indica hasUpdate = false si la versión instalada es igual o mayor', () {
      final service = UpdateCheckerService();
      final info = service.parseReleaseJson(
        mockReleaseJson,
        currentVersionOverride: '1.0.1',
        platformOverride: 'windows',
      );

      expect(info.hasUpdate, isFalse);
    });
  });

  group('AppUpdateInfo - Propiedades formateadas', () {
    test('Formatea correctamente el tamaño en MB y fecha en español', () {
      final info = AppUpdateInfo(
        hasUpdate: true,
        currentVersion: '1.0.0',
        latestVersion: '1.0.1',
        releaseName: 'Update 1.0.1',
        releaseNotes: 'Notas',
        fileSizeBytes: 10485760, // Exactamente 10.0 MB
        publishedAt: DateTime(2026, 11, 5),
      );

      expect(info.formattedFileSize, '10.0 MB');
      expect(info.formattedDate, '05/11/2026');
    });

    test('Maneja valores nulos o 0 en tamaño y fecha', () {
      const info = AppUpdateInfo(
        hasUpdate: false,
        currentVersion: '1.0.0',
        latestVersion: '1.0.0',
        releaseName: 'Actual',
        releaseNotes: '',
      );

      expect(info.formattedFileSize, '');
      expect(info.formattedDate, '');
    });
  });
}

