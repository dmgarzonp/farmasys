import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Servicio responsable de recopilar identificadores de hardware de bajo nivel
/// de forma segura en plataformas de escritorio (Windows, Linux, macOS)
/// para crear una huella digital única (Hardware Fingerprint / Machine ID).
class HardwareFingerprintService {
  static String? _cachedMachineId;

  /// Retorna un identificador único formateado del equipo (ej: FARM-MCH-9B4F-8A2C-1E30)
  static Future<String> getMachineId() async {
    if (_cachedMachineId != null) return _cachedMachineId!;

    String rawId = '';
    try {
      if (Platform.isLinux) {
        rawId = await _getLinuxId();
      } else if (Platform.isWindows) {
        rawId = await _getWindowsId();
      } else if (Platform.isMacOS) {
        rawId = await _getMacId();
      }
    } catch (_) {
      // Ignorar excepciones de permisos para no bloquear la aplicación
    }

    // Fallback seguro si la plataforma o permisos restringen el acceso al hardware
    if (rawId.trim().isEmpty) {
      rawId = '${Platform.localHostname}-${Platform.operatingSystem}-${Platform.numberOfProcessors}';
    }

    // Hashing criptográfico SHA-256 con sal interna para ofuscar identificadores crudos
    final bytes = utf8.encode('FARMSYS_HW_SALT_2026_$rawId');
    final digest = sha256.convert(bytes);
    final hex = digest.toString().toUpperCase();

    // Formato amigable de 16 caracteres hexadecimales agrupados
    _cachedMachineId =
        'FARM-MCH-${hex.substring(0, 4)}-${hex.substring(4, 8)}-${hex.substring(8, 12)}';

    return _cachedMachineId!;
  }

  /// Extrae el ID de máquina en sistemas Linux (/etc/machine-id o D-Bus)
  static Future<String> _getLinuxId() async {
    // 1. /etc/machine-id
    final machineIdFile = File('/etc/machine-id');
    if (await machineIdFile.exists()) {
      final content = await machineIdFile.readAsString();
      if (content.trim().isNotEmpty) return content.trim();
    }

    // 2. /var/lib/dbus/machine-id
    final dbusFile = File('/var/lib/dbus/machine-id');
    if (await dbusFile.exists()) {
      final content = await dbusFile.readAsString();
      if (content.trim().isNotEmpty) return content.trim();
    }

    // 3. /sys/class/dmi/id/product_uuid
    final dmiUuidFile = File('/sys/class/dmi/id/product_uuid');
    if (await dmiUuidFile.exists()) {
      final content = await dmiUuidFile.readAsString();
      if (content.trim().isNotEmpty) return content.trim();
    }

    return '';
  }

  /// Extrae el UUID de la placa base o BIOS en Windows vía PowerShell o WMIC
  static Future<String> _getWindowsId() async {
    try {
      // PowerShell moderno (Windows 10 / 11)
      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-Command', '(Get-CimInstance Win32_ComputerSystemProduct).UUID'],
      );
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        final uuid = result.stdout.toString().trim();
        if (uuid.length > 5) return uuid;
      }
    } catch (_) {}

    try {
      // Fallback a wmic clásico
      final result = await Process.run('wmic', ['csproduct', 'get', 'uuid']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && !trimmed.toLowerCase().contains('uuid')) {
            return trimmed;
          }
        }
      }
    } catch (_) {}

    return '';
  }

  /// Extrae el UUID de la plataforma en macOS
  static Future<String> _getMacId() async {
    try {
      final result = await Process.run('ioreg', ['-rd1', '-c', 'IOPlatformExpertDevice']);
      if (result.exitCode == 0) {
        final match = RegExp(r'"IOPlatformUUID"\s*=\s*"([^"]+)"')
            .firstMatch(result.stdout.toString());
        if (match != null) return match.group(1) ?? '';
      }
    } catch (_) {}
    return '';
  }
}

