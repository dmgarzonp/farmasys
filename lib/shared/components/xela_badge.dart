import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Variantes semánticas para los indicadores tipo Pill Badge de Xela UI Kit
enum XelaBadgeVariant {
  success,
  warning,
  danger,
  info,
  purple,
  neutral,
  primary,
}

/// Etiqueta tipo Píldora (*Pill Badge*) de alta densidad estética según Xela UI Kit
class XelaBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final XelaBadgeVariant variant;
  final bool isPill;

  const XelaBadge({
    super.key,
    required this.text,
    this.icon,
    this.variant = XelaBadgeVariant.neutral,
    this.isPill = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    switch (variant) {
      case XelaBadgeVariant.success:
        bg = AppColors.pillSuccessBg;
        textColor = AppColors.pillSuccessText;
        break;
      case XelaBadgeVariant.warning:
        bg = AppColors.pillWarningBg;
        textColor = AppColors.pillWarningText;
        break;
      case XelaBadgeVariant.danger:
        bg = AppColors.pillDangerBg;
        textColor = AppColors.pillDangerText;
        break;
      case XelaBadgeVariant.info:
        bg = AppColors.pillInfoBg;
        textColor = AppColors.pillInfoText;
        break;
      case XelaBadgeVariant.purple:
        bg = AppColors.pillPurpleBg;
        textColor = AppColors.pillPurpleText;
        break;
      case XelaBadgeVariant.primary:
        bg = AppColors.primarySurface;
        textColor = AppColors.primaryDark;
        break;
      case XelaBadgeVariant.neutral:
        bg = AppColors.pillNeutralBg;
        textColor = AppColors.pillNeutralText;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPill ? 8 : 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isPill ? 20 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
