import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            // ★ Figma exact: light gray fill #F1F5F9 for normal, light red for error
            color: hasError ? AppTheme.errorLight5 : AppTheme.bgPage,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError ? AppTheme.signalRed : AppTheme.borderLight,
              width: hasError ? 1.4 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            onChanged: onChanged,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: hasError ? AppTheme.signalRed : AppTheme.textMuted,
                size: 20,
              ),
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        suffixIcon,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: onSuffixTap,
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.signalRed, size: 14),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(
                  color: AppTheme.signalRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
