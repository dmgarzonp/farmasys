import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';

/// Badge visual que evalúa y categoriza el vencimiento de un lote según su urgencia
class ExpirationBadge extends StatelessWidget {
  final DateTime expirationDate;
  final DateTime? referenceDate;

  const ExpirationBadge({
    super.key,
    required this.expirationDate,
    this.referenceDate,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = referenceDate ?? DateTime.now();
    final DateTime exp = DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int diffDays = exp.difference(today).inDays;

    final Color bgColor;
    final Color textColor;
    final String label;

    if (diffDays < 0) {
      bgColor = AppColors.lotExpired;
      textColor = AppColors.lotExpiredText;
      label = 'VENCIDO (${diffDays.abs()}d)';
    } else if (diffDays <= 30) {
      bgColor = AppColors.lotWarning;
      textColor = AppColors.lotWarningText;
      label = 'PRÓXIMO (${diffDays}d)';
    } else {
      bgColor = AppColors.lotOptimal;
      textColor = AppColors.lotOptimalText;
      label = AppFormatters.date(expirationDate);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
