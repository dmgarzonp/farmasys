import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/database/app_database.dart';
import 'package:farmsys/core/database/database_seeder.dart';
import 'package:farmsys/core/database/tables/usuarios_table.dart';
import 'package:farmsys/core/security/password_hasher.dart';
import 'package:farmsys/features/auth/data/drift_auth_repository.dart';

void main() {
  late AppDatabase db;
  late DriftAuthRepository authRepository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    authRepository = DriftAuthRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftAuthRepository - Autenticación Segura y Sal Criptográfica', () {
    test('Login exitoso con usuario administrador seeded por defecto y contraseña admin123', () async {
      final user = await authRepository.login('admin', 'admin123');

      expect(user.id, equals(1));
      expect(user.username, equals('admin'));
      expect(user.role, equals(UserRole.administrador));
      expect(user.isActive, isTrue);
    });

    test('Login falla cuando la contraseña es errónea', () async {
      expect(
        () => authRepository.login('admin', 'password_invalida'),
        throwsA(isA<Exception>()),
      );
    });

    test('Login falla cuando el usuario no existe', () async {
      expect(
        () => authRepository.login('usuario_fantasma', '123456'),
        throwsA(isA<Exception>()),
      );
    });

    test('Auto-migración transparente de hash legado a hash salado al iniciar sesión', () async {
      // Creamos un usuario de prueba con hash legado plano SHA-256 (sin sal)
      const testUser = 'cajero_antiguo';
      const testPass = 'claveCajero123';
      final legacyHash = sha256.convert(utf8.encode(testPass)).toString();

      await db.into(db.usuariosTable).insert(
        UsuariosTableCompanion.insert(
          username: testUser,
          passwordHash: legacyHash,
          role: UserRole.cajero,
        ),
      );

      // Verificamos que inicialmente tiene el hash sin sal
      final userBefore = await (db.select(db.usuariosTable)..where((t) => t.username.equals(testUser))).getSingle();
      expect(PasswordHasher.needsRehash(userBefore.passwordHash), isTrue);

      // El usuario inicia sesión
      final loggedUser = await authRepository.login(testUser, testPass);
      expect(loggedUser.username, equals(testUser));

      // Verificamos que la base de datos se actualizó automáticamente al hash con sal
      final userAfter = await (db.select(db.usuariosTable)..where((t) => t.username.equals(testUser))).getSingle();
      expect(PasswordHasher.needsRehash(userAfter.passwordHash), isFalse);
      expect(userAfter.passwordHash.startsWith('v1\$'), isTrue);
      expect(PasswordHasher.verify(testPass, userAfter.passwordHash), isTrue);
    });

    test('changePassword almacena la nueva contraseña con formato salado', () async {
      await authRepository.changePassword(1, 'NuevaSuperClave2026!');

      final adminAfter = await (db.select(db.usuariosTable)..where((t) => t.id.equals(1))).getSingle();
      expect(adminAfter.passwordHash.startsWith('v1\$'), isTrue);
      expect(PasswordHasher.verify('NuevaSuperClave2026!', adminAfter.passwordHash), isTrue);
      expect(adminAfter.requiresPasswordChange, isFalse);

      // El login funciona inmediatamente con la nueva clave
      final user = await authRepository.login('admin', 'NuevaSuperClave2026!');
      expect(user.id, equals(1));
    });
  });
}

