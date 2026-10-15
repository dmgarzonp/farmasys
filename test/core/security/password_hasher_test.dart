import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/security/password_hasher.dart';

void main() {
  group('PasswordHasher - Sal Criptográfica y Protección de Contraseñas', () {
    test('generateSalt genera cadenas aleatorias en hexadecimal de la longitud esperada', () {
      final salt1 = PasswordHasher.generateSalt(16);
      final salt2 = PasswordHasher.generateSalt(16);

      expect(salt1.length, equals(32)); // 16 bytes = 32 caracteres hex
      expect(salt2.length, equals(32));
      expect(salt1, isNot(equals(salt2)));
    });

    test('hashPassword produce el formato estándar v1\$salt\$digest', () {
      final hash = PasswordHasher.hashPassword('MiContraseñaSegura123!');

      expect(hash.startsWith('v1\$'), isTrue);
      final parts = hash.split('\$');
      expect(parts.length, equals(3));
      expect(parts[0], equals('v1'));
      expect(parts[1].length, equals(32)); // Salt de 16 bytes
      expect(parts[2].length, equals(64)); // SHA-256 hex digest
    });

    test('La misma contraseña genera hashes completamente distintos con sales diferentes (Anti-Rainbow Tables)', () {
      const password = 'FarmaciaPassword2026';
      final hashA = PasswordHasher.hashPassword(password);
      final hashB = PasswordHasher.hashPassword(password);

      expect(hashA, isNot(equals(hashB)));
      expect(PasswordHasher.verify(password, hashA), isTrue);
      expect(PasswordHasher.verify(password, hashB), isTrue);
    });

    test('verify rechaza contraseñas incorrectas', () {
      final hash = PasswordHasher.hashPassword('ClaveCorrecta987');

      expect(PasswordHasher.verify('ClaveCorrecta987', hash), isTrue);
      expect(PasswordHasher.verify('ClaveIncorrecta', hash), isFalse);
      expect(PasswordHasher.verify('clavecorrecta987', hash), isFalse);
    });

    test('verify y needsRehash soportan y detectan compatibilidad con hashes legados sin sal', () {
      const plainPassword = 'admin123';
      // Hash plano SHA-256 de 'admin123'
      final legacyPlainHash = sha256.convert(utf8.encode(plainPassword)).toString();

      // Debe verificar exitosamente
      expect(PasswordHasher.verify(plainPassword, legacyPlainHash), isTrue);
      expect(PasswordHasher.verify('otraClave', legacyPlainHash), isFalse);

      // Debe señalar que necesita re-hash
      expect(PasswordHasher.needsRehash(legacyPlainHash), isTrue);

      // El hash moderno no debe necesitar re-hash
      final modernHash = PasswordHasher.hashPassword(plainPassword);
      expect(PasswordHasher.needsRehash(modernHash), isFalse);
    });
  });
}

