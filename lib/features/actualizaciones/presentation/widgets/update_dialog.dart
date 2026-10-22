import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../domain/entities/app_update_info.dart';
import '../../domain/services/update_checker_service.dart';

/// Diálogo interactivo para descargar e instalar la actualización oficial de FarmSys
class UpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final UpdateCheckerService service;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.service,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    required UpdateCheckerService service,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpdateDialog(
        updateInfo: updateInfo,
        service: service,
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  bool _isInstalling = false;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String? _errorMessage;
  File? _downloadedFile;

  Future<void> _startDownload() async {
    final url = widget.updateInfo.downloadUrl;
    final fileName = widget.updateInfo.fileName;

    if (url == null || fileName == null) {
      setState(() {
        _errorMessage = 'No se encontró un instalador compatible para este sistema operativo.';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _progress = 0.0;
    });

    try {
      final file = await widget.service.downloadInstaller(
        downloadUrl: url,
        fileName: fileName,
        onProgress: (progress, received, total) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _receivedBytes = received;
              _totalBytes = total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadedFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Error durante la descarga: $e';
        });
      }
    }
  }

  Future<void> _applyUpdate() async {
    if (_downloadedFile == null) return;
    setState(() {
      _isInstalling = true;
      _errorMessage = null;
    });

    try {
      await widget.service.launchInstallerAndExit(_downloadedFile!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInstalling = false;
          _errorMessage = '$e'.replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = widget.updateInfo;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colors.surface,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.system_update_rounded, color: colors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualización Disponible',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'FarmSys v${info.latestVersion}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildVersionBadge('Versión Actual', 'v${info.currentVersion}', colors.textSecondary),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: colors.textMuted),
                  _buildVersionBadge('Nueva Versión', 'v${info.latestVersion}', colors.success),
                  if (info.formattedFileSize.isNotEmpty) ...[
                    Container(height: 24, width: 1, color: colors.borderLight),
                    _buildVersionBadge('Tamaño', info.formattedFileSize, colors.textPrimary),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (info.releaseNotes.isNotEmpty) ...[
              Text(
                'Novedades y Cambios:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.borderLight),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    info.releaseNotes,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isDownloading) ...[
              Text(
                'Descargando instalador... ${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: colors.borderLight,
                  color: colors.primary,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(_receivedBytes / (1024 * 1024)).toStringAsFixed(1)} MB de ${(_totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                style: TextStyle(fontSize: 11, color: colors.textMuted),
              ),
            ] else if (_downloadedFile != null && !_isInstalling) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.pillSuccessBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: colors.pillSuccessText, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¡Descarga completada! Al presionar el botón, se aplicará la actualización. Todos tus datos y ventas permanecerán 100% intactos.',
                        style: TextStyle(fontSize: 12, color: colors.pillSuccessText, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_isInstalling) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Instalando actualización... Por favor ingresa tu contraseña en la ventana de autenticación del sistema para completar.',
                        style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 12, color: colors.danger),
                    ),
                    if (_downloadedFile != null && Platform.isLinux) ...[
                      const SizedBox(height: 8),
                      Text(
                        'También puedes instalarlo manualmente ejecutando en la terminal:',
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SelectableText(
                                'sudo dpkg -i "${_downloadedFile!.path}"',
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            tooltip: 'Copiar comando',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: 'sudo dpkg -i "${_downloadedFile!.path}"'));
                              AppSnackBars.showSuccess(context, message: 'Comando copiado al portapapeles');
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isDownloading && !_isInstalling && _downloadedFile == null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Recordar Más Tarde', style: TextStyle(color: colors.textSecondary)),
          ),
        if (!_isDownloading && !_isInstalling && _downloadedFile == null)
          AppButton(
            label: 'Descargar e Instalar',
            icon: Icons.download_rounded,
            onPressed: _startDownload,
          ),
        if (_downloadedFile != null && !_isInstalling) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: colors.textSecondary)),
          ),
          AppButton(
            label: 'Reiniciar e Instalar Ahora',
            icon: Icons.restart_alt_rounded,
            onPressed: _applyUpdate,
          ),
        ],
        if (_isInstalling)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Instalando...',
              style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildVersionBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
