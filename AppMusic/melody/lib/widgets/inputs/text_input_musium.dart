import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Musium text input field
/// Supports different input types (email, password, search, etc.)
class TextInputMusium extends StatefulWidget {
  /// Input field label
  final String? label;

  /// Input field hint text
  final String? hint;

  /// Text controller
  final TextEditingController? controller;

  /// Input type (email, password, search, text)
  final TextInputType keyboardType;

  /// Whether this is a password field
  final bool isPassword;

  /// Whether to show search icon
  final bool isSearch;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submitted callback
  final ValueChanged<String>? onSubmitted;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom border color
  final Color? borderColor;

  /// Custom text color
  final Color? textColor;

  /// Border radius
  final double borderRadius;

  /// Icon on the left side
  final IconData? prefixIcon;

  /// Icon on the right side
  final IconData? suffixIcon;

  /// Suffix icon callback
  final VoidCallback? onSuffixIconPressed;

  /// Input height
  final double height;

  /// Whether the field is enabled
  final bool enabled;

  /// Maximum lines (null for unlimited)
  final int? maxLines;

  /// Minimum lines
  final int minLines;

  /// Maximum characters
  final int? maxLength;

  const TextInputMusium({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isSearch = false,
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderRadius = 8,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.height = 48,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
  }) : super(key: key);

  @override
  State<TextInputMusium> createState() => _TextInputMusiumState();
}

class _TextInputMusiumState extends State<TextInputMusium> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColorMusium.darkSurfaceLight;
    final borderColor = widget.borderColor ?? AppColorMusium.textTertiary;
    final textColor = widget.textColor ?? AppColorMusium.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypographyMusium.labelLarge.copyWith(
              color: AppColorMusium.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Input field
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.enabled ? bgColor : bgColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color:
                  widget.enabled ? borderColor : borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            style: AppTypographyMusium.bodyLarge.copyWith(
              color: textColor,
            ),
            cursorColor: AppColorMusium.accentTeal,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.height > 48 ? 12 : 8,
              ),
              hintText: widget.hint,
              hintStyle: AppTypographyMusium.bodyMedium.copyWith(
                color: AppColorMusium.textTertiary,
              ),
              prefixIcon: widget.prefixIcon != null || widget.isSearch
                  ? Icon(
                      widget.prefixIcon ?? Icons.search,
                      color: AppColorMusium.textSecondary,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColorMusium.textSecondary,
                        size: 20,
                      ),
                    )
                  : widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixIconPressed,
                          child: Icon(
                            widget.suffixIcon,
                            color: AppColorMusium.textSecondary,
                            size: 20,
                          ),
                        )
                      : null,
              counter: widget.maxLength != null
                  ? Text(
                      '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                      style: AppTypographyMusium.bodySmall.copyWith(
                        color: AppColorMusium.textTertiary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
