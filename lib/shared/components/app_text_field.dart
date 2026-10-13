import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Campo de entrada de texto estandarizado para escritorio con gestión de foco
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autoFocus;
  final bool readOnly;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? shortcutBadge;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final String? errorText;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.shortcutBadge,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autoFocus,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: TextStyle(
            fontSize: 13,
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            errorText: errorText,
            hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: colors.textMuted)
                : null,
            suffixIcon: shortcutBadge != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: UnconstrainedBox(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          shortcutBadge!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                : suffix,
            filled: true,
            fillColor: readOnly ? colors.inputReadOnlyFill : colors.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.danger),
            ),
          ),
        ),
      ],
    );
  }
}
