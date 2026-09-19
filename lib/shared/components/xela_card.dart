import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Tarjeta modular basada en el sistema de diseño Xela UI Kit (Setproduct)
/// Presenta bordes sutiles de 1px, radio de 12px y elevación limpia para escritorio.
class XelaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final Widget? header;

  const XelaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.border,
    this.onTap,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12);
    final effectiveBorder = border ?? Border.all(color: AppColors.border, width: 1);

    final content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBackground,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000), // Sombra hiper-sutil Xela
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: header == null
            ? Padding(padding: padding, child: child)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  header!,
                  const Divider(height: 1, color: AppColors.border),
                  Padding(padding: padding, child: child),
                ],
              ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        hoverColor: AppColors.primary.withValues(alpha: 0.04),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        child: content,
      );
    }

    return content;
  }
}
