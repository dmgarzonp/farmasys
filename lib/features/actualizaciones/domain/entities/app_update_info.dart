/// Entidad que representa la información de una versión de actualización de FarmSys
class AppUpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseName;
  final String releaseNotes;
  final DateTime? publishedAt;
  final String? downloadUrl;
  final String? fileName;
  final int fileSizeBytes;

  const AppUpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseNotes,
    this.publishedAt,
    this.downloadUrl,
    this.fileName,
    this.fileSizeBytes = 0,
  });

  /// Formatea el tamaño del archivo en Megabytes amigables
  String get formattedFileSize {
    if (fileSizeBytes <= 0) return '';
    final mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Fecha formateada en español
  String get formattedDate {
    if (publishedAt == null) return '';
    final d = publishedAt!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

