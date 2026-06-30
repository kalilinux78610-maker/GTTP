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
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final Iterable<String>? autofillHints;

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
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.autofillHints,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? AppTheme.signalRed : AppTheme.borderMid,
              width: hasError ? 1.4 : 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType ??
                (isPassword ? TextInputType.visiblePassword : TextInputType.text),
            textInputAction: textInputAction,
            autocorrect: isPassword ? false : autocorrect,
            enableSuggestions: !isPassword,
            autofillHints: autofillHints,
            onChanged: onChanged,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
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
