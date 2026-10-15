import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Servicio criptográfico para hashing y verificación de contraseñas de usuarios.
/// Implementa sal (*salt*) criptográfica pseudoaleatoria y pepper para impedir ataques
/// basados en tablas arcoíris (*rainbow tables*) o ataques de diccionario offline.
class PasswordHasher {
  static const String _formatPrefix = 'v1\$';
  static const String _pepper = 'FARMSYS_USER_PEPPER_2026';

  /// Genera una sal criptográfica pseudoaleatoria en formato hexadecimal (16 bytes = 32 caracteres)
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Calcula el hash con sal de una contraseña.
  /// Formato de almacenamiento: `v1$[salt]$[hash_sha256]`
  static String hashPassword(String password, {String? salt}) {
    final effectiveSalt = salt ?? generateSalt();
    final digest = sha256
        .convert(utf8.encode('$effectiveSalt:$password:$_pepper'))
        .toString();
    return '$_formatPrefix$effectiveSalt\$$digest';
  }

  /// Valida una contraseña contra un hash almacenado.
  /// Soporta el formato salado (`v1$[salt]$[digest]`) y mantiene compatibilidad
  /// retrospectiva con hashes heredados sin sal (SHA-256 plano de 64 caracteres hex).
  static bool verify(String password, String storedHash) {
    if (storedHash.startsWith(_formatPrefix)) {
      final parts = storedHash.split('\$');
      if (parts.length == 3) {
        final salt = parts[1];
        final expectedDigest = parts[2];
        final actualDigest = sha256
            .convert(utf8.encode('$salt:$password:$_pepper'))
            .toString();
        return actualDigest == expectedDigest;
      }
    }

    // Compatibilidad retrospectiva con hashes heredados sin sal (SHA-256 plano de 64 caracteres)
    final legacyHash = sha256.convert(utf8.encode(password)).toString();
    return legacyHash == storedHash;
  }

  /// Determina si un hash almacenado es antiguo (sin sal) y debe migrarse a salado
  static bool needsRehash(String storedHash) {
    return !storedHash.startsWith(_formatPrefix);
  }
}

