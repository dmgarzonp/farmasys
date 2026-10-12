import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleDriveService {
  // Credenciales inyectadas en tiempo de compilación mediante:
  // --dart-define-from-file=secrets.json
  static const _clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const _clientSecret = String.fromEnvironment('GOOGLE_CLIENT_SECRET');

  static const _scopes = [
    drive.DriveApi.driveFileScope,
    'https://www.googleapis.com/auth/userinfo.email',
  ];
  static const _backupFolderName = 'FarmSys_Backups';

  static const _prefRefreshToken = 'gdrive_refresh_token';
  static const _prefAccessToken = 'gdrive_access_token';
  static const _prefTokenExpiry = 'gdrive_token_expiry';
  static const _prefUserEmail = 'gdrive_user_email';

  AutoRefreshingAuthClient? _client;
  String? _currentUserEmail;

  bool get isAuthenticated => _client != null;
  String? get currentUserEmail => _currentUserEmail;

  /// Restaura la sesión persistente de Google Drive si existe token guardado
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_prefRefreshToken);
    final userEmail = prefs.getString(_prefUserEmail);
    final accessTokenData = prefs.getString(_prefAccessToken);
    final expiryStr = prefs.getString(_prefTokenExpiry);

    if (refreshToken != null &&
        refreshToken.isNotEmpty &&
        _clientId.isNotEmpty &&
        _clientSecret.isNotEmpty) {
      _currentUserEmail = userEmail;
      try {
        final clientId = ClientId(_clientId, _clientSecret);
        final expiry = expiryStr != null ? DateTime.parse(expiryStr) : DateTime.now().toUtc();
        final credentials = AccessCredentials(
          AccessToken('Bearer', accessTokenData ?? '', expiry),
          refreshToken,
          _scopes,
        );
        _client = autoRefreshingClient(clientId, credentials, http.Client());
      } catch (e) {
        // En caso de error restaurando sesión, limpiar tokens inválidos
        await signOut();
      }
    }
  }

  /// Inicia el flujo de autenticación OAuth 2.0 y retorna el email de la cuenta conectada
  Future<String> authenticate() async {
    if (_clientId.isEmpty || _clientSecret.isEmpty) {
      throw Exception(
        'Las credenciales de Google OAuth no han sido inyectadas en esta versión. '
        'Por favor, compila el ejecutable con: --dart-define-from-file=secrets.json',
      );
    }

    final clientId = ClientId(_clientId, _clientSecret);

    // Usa un servidor local en el puerto 0 (se asigna automáticamente) para recibir el token
    _client = await clientViaUserConsent(
      clientId,
      _scopes,
      (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          print('Por favor navega a esta URL en tu navegador: $url');
        }
      },
    );

    // Obtener la información de la cuenta conectada
    String email = 'Cuenta de Google Conectada';
    try {
      final driveApi = drive.DriveApi(_client!);
      final about = await driveApi.about.get($fields: 'user(emailAddress,displayName)');
      if (about.user?.emailAddress != null && about.user!.emailAddress!.isNotEmpty) {
        email = about.user!.emailAddress!;
      }
    } catch (e) {
      print('Advertencia al consultar perfil de usuario en Drive: $e');
    }

    _currentUserEmail = email;

    // Persistir tokens y correo en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = _client?.credentials.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_prefRefreshToken, refreshToken);
    }
    if (_client?.credentials.accessToken != null) {
      await prefs.setString(_prefAccessToken, _client!.credentials.accessToken.data);
      await prefs.setString(_prefTokenExpiry, _client!.credentials.accessToken.expiry.toIso8601String());
    }
    await prefs.setString(_prefUserEmail, email);

    return email;
  }

  /// Sube o sobrescribe un archivo de base de datos en la carpeta especificada en Drive
  Future<void> uploadDatabaseBackup(File dbFile) async {
    if (_client == null) {
      throw Exception('Usuario no autenticado en Google Drive');
    }

    final driveApi = drive.DriveApi(_client!);

    // 1. Buscar si la carpeta existe
    String? folderId = await _getFolderId(driveApi, _backupFolderName);

    // 2. Si no existe, crearla
    if (folderId == null) {
      final folder = drive.File()
        ..name = _backupFolderName
        ..mimeType = 'application/vnd.google-apps.folder';
      final createdFolder = await driveApi.files.create(folder);
      folderId = createdFolder.id;
    }

    if (folderId == null) throw Exception('No se pudo crear ni encontrar la carpeta en Drive');

    // 3. Subir el archivo
    final fileName = p.basename(dbFile.path);
    final fileToUpload = drive.File()
      ..name = fileName
      ..parents = [folderId];

    final media = drive.Media(dbFile.openRead(), dbFile.lengthSync());

    await driveApi.files.create(fileToUpload, uploadMedia: media);
  }

  Future<String?> _getFolderId(drive.DriveApi api, String folderName) async {
    final query = "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false";
    final fileList = await api.files.list(q: query, $fields: 'files(id, name)');
    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id;
    }
    return null;
  }

  /// Cierra la sesión activa, revoca memoria y elimina tokens persistidos
  Future<void> signOut() async {
    _client?.close();
    _client = null;
    _currentUserEmail = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefRefreshToken);
    await prefs.remove(_prefAccessToken);
    await prefs.remove(_prefTokenExpiry);
    await prefs.remove(_prefUserEmail);
  }
}

final googleDriveService = GoogleDriveService();
