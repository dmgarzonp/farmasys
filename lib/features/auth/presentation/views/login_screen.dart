import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/constants/constants.dart';
import '../../../../shared/extensions/theme_extensions.dart';
import '../../../configuraciones/domain/settings_state.dart';
import '../../../configuraciones/presentation/controllers/settings_notifier.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with WindowListener {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _setupWindow();
  }

  Future<void> _setupWindow() async {
    await windowManager.setPreventClose(true);
  }

  @override
  void onWindowClose() async {
    await windowManager.destroy();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/');
    }
  }

  List<Color> _getHeroGradientColors(Color primary) {
    // ignore: deprecated_member_use
    final value = primary.value;
    switch (value) {
      case 0xFF059669: // Esmeralda Salud
        return const [
          Color(0xFF022C22),
          Color(0xFF064E3B),
          Color(0xFF047857),
        ];
      case 0xFF0284C7: // Azul Clínico
        return const [
          Color(0xFF082F49),
          Color(0xFF0369A1),
          Color(0xFF0284C7),
        ];
      case 0xFF0D9488: // Turquesa Laboratorio
        return const [
          Color(0xFF042F2E),
          Color(0xFF0F766E),
          Color(0xFF0D9488),
        ];
      case 0xFF6366F1: // Índigo Dermocosmética
        return const [
          Color(0xFF1E1B4B),
          Color(0xFF4338CA),
          Color(0xFF6366F1),
        ];
      case 0xFFDC2626: // Carmín Cruz Médica
        return const [
          Color(0xFF450A0A),
          Color(0xFF991B1B),
          Color(0xFFDC2626),
        ];
      case 0xFFD97706: // Ámbar Vital
        return const [
          Color(0xFF451A03),
          Color(0xFFB45309),
          Color(0xFFD97706),
        ];
      default:
        final hsl = HSLColor.fromColor(primary);
        final darkShade = hsl.withLightness(0.12).withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0)).toColor();
        final midShade = hsl.withLightness(0.24).toColor();
        return [darkShade, midShade, primary];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final settings = ref.watch(settingsProvider);
    final colors = context.colors;
    final isDark = context.isDark;
    final heroGradientColors = _getHeroGradientColors(settings.primaryColor);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // Barra superior de ventana nativa (Window Drag & Caption)
          SizedBox(
            height: 38,
            child: WindowCaption(
              brightness: Brightness.dark,
              backgroundColor: heroGradientColors.first,
              title: Row(
                children: [
                  Icon(Icons.local_pharmacy_rounded, size: 16, color: colors.primaryLight),
                  const SizedBox(width: 8),
                  Text(
                    '${settings.pharmacyName} - Inicio de Sesión',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cuerpo de la pantalla con diseño responsive
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 880;

                if (isWide) {
                  return Row(
                    children: [
                      // Panel Izquierdo: Branding y Valor Institucional (Hero Panel)
                      Expanded(
                        flex: 5,
                        child: _buildHeroPanel(colors, settings, heroGradientColors),
                      ),

                      // Panel Derecho: Formulario de Acceso Limpio y Premium
                      Expanded(
                        flex: 6,
                        child: Container(
                          color: isDark ? colors.background : const Color(0xFFF8FAFC),
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: _buildLoginForm(authState, colors, settings, isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Vista adaptativa para ventanas más estrechas
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: heroGradientColors,
                      ),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: isDark ? colors.cardBackground : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: _buildLoginForm(authState, colors, settings, isDark, showHeaderLogo: true),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Panel Hero Institucional adaptado al color corporativo
  Widget _buildHeroPanel(AppThemeColors colors, SettingsState settings, List<Color> heroColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: heroColors,
        ),
      ),
      child: Stack(
        children: [
          // Elementos decorativos de fondo con destellos sutiles
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryLight.withValues(alpha: 0.10),
              ),
            ),
          ),

          // Contenido principal del panel Hero
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cabecera de marca con insignia de versión
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: colors.primaryLight),
                          const SizedBox(width: 6),
                          const Text(
                            'FarmSys v1.0 • Edición Comercial',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Centro: Presentación de la marca y características
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_pharmacy_rounded,
                          size: 38,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      settings.pharmacyName.isEmpty ? 'FarmSys' : settings.pharmacyName,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión inteligente de farmacias, punto de venta y facturación electrónica.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Tarjetas de características clave
                    _buildFeatureItem(
                      icon: Icons.point_of_sale_rounded,
                      title: 'Punto de Venta de Alta Velocidad',
                      description: 'Cobro ágil con tickets térmicos, redondeos y arqueos de caja.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.inventory_2_rounded,
                      title: 'Trazabilidad y Lotes ARCSA',
                      description: 'Control estricto de fechas de vencimiento y semáforo preventivo.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.receipt_long_rounded,
                      title: 'Facturación Electrónica SRI',
                      description: 'Emisión nativa con firma digital .p12 y validación en línea.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.cloud_done_rounded,
                      title: 'Respaldos Seguros y Automatizados',
                      description: 'Protección local y sincronización directa con Google Drive.',
                    ),
                  ],
                ),

                // Pie del panel Hero
                Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 8),
                    Text(
                      'Arquitectura Offline-First con base de datos local SQLite',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ítem visual de características para el panel Hero
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formulario de autenticación estilizado y adaptado a Modo Oscuro y Color Corporativo
  Widget _buildLoginForm(
    AuthState authState,
    AppThemeColors colors,
    SettingsState settings,
    bool isDark, {
    bool showHeaderLogo = false,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeaderLogo) ...[
            Center(
              child: Icon(
                Icons.local_pharmacy_rounded,
                size: 50,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Cabecera del formulario
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ACCESO AUTORIZADO',
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Iniciar Sesión',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ingresa tus credenciales para acceder a tu turno de trabajo.',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Alerta de error en caso de credenciales inválidas
          if (authState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: colors.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authState.errorMessage!,
                      style: TextStyle(
                        color: colors.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Campo: Usuario
          TextFormField(
            controller: _usernameController,
            style: TextStyle(fontSize: 14, color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Usuario',
              labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
              hintText: 'ej. administrador o cajero',
              hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
              prefixIcon: Icon(Icons.person_outline_rounded, color: colors.textSecondary, size: 20),
              filled: true,
              fillColor: isDark ? colors.cardBackground : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.8),
              ),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Ingresa tu nombre de usuario' : null,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 18),

          // Campo: Contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(fontSize: 14, color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
              hintText: '••••••••',
              hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.textSecondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: colors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: isDark ? colors.cardBackground : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.8),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Ingresa tu contraseña' : null,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 28),

          // Botón principal de acceso
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                elevation: 1,
                shadowColor: colors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ingresar al Sistema',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Nota al pie con nombre dinámico de farmacia
          Center(
            child: Text(
              '${settings.pharmacyName} • FarmSys POS',
              style: TextStyle(
                fontSize: 11,
                color: colors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
