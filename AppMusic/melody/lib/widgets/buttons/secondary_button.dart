import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Secondary button widget - Outline style
/// Used for secondary call-to-action buttons
class SecondaryButton extends StatefulWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Optional icon to display on the left
  final IconData? icon;

  /// Button width (defaults to full width)
  final double? width;

  /// Button height (defaults to 48px)
  final double height;

  /// Custom border color (defaults to teal)
  final Color? borderColor;

  /// Custom text color (defaults to teal)
  final Color? textColor;

  /// Border radius (defaults to 8px)
  final double borderRadius;

  /// Border width
  final double borderWidth;

  /// Padding inside button
  final EdgeInsets padding;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height = 48,
    this.borderColor,
    this.textColor,
    this.borderRadius = 8,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) : super(key: key);

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePressDown(PointerDownEvent event) {
    if (!widget.isDisabled) {
      _animationController.forward();
    }
  }

  void _handlePressUp(PointerUpEvent event) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? AppColorMusium.accentTeal;
    final textColor = widget.textColor ?? AppColorMusium.accentTeal;
    final isActive = !widget.isDisabled;

    return Listener(
      onPointerDown: isActive ? _handlePressDown : null,
      onPointerUp: isActive ? _handlePressUp : null,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        ),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: OutlinedButton(
            onPressed: isActive ? widget.onPressed : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isActive ? borderColor : borderColor.withOpacity(0.3),
                width: widget.borderWidth,
              ),
              foregroundColor: textColor,
              disabledForegroundColor: textColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              padding: widget.padding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: AppTypographyMusium.labelLarge.copyWith(
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
