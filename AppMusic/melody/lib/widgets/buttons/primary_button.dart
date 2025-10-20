import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Primary button widget - Teal/Cyan accent color
/// Used for main call-to-action buttons
class PrimaryButton extends StatefulWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Whether the button is loading
  final bool isLoading;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Optional icon to display on the left
  final IconData? icon;

  /// Button width (defaults to full width)
  final double? width;

  /// Whether button should take full width
  final bool fullWidth;

  /// Button height (defaults to 48px)
  final double height;

  /// Custom background color (defaults to teal)
  final Color? backgroundColor;

  /// Custom text color (defaults to black)
  final Color? textColor;

  /// Border radius (defaults to 8px)
  final double borderRadius;

  /// Padding inside button
  final EdgeInsets padding;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.fullWidth = false,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
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
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handlePressUp(PointerUpEvent event) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColorMusium.accentTeal;
    final textColor = widget.textColor ?? Colors.black;
    final isActive = !widget.isDisabled && !widget.isLoading;

    return Listener(
      onPointerDown: isActive ? _handlePressDown : null,
      onPointerUp: isActive ? _handlePressUp : null,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        ),
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : (widget.width ?? null),
          height: widget.height,
          child: ElevatedButton(
            onPressed: isActive ? widget.onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? bgColor : bgColor.withOpacity(0.5),
              foregroundColor: textColor,
              disabledBackgroundColor: bgColor.withOpacity(0.5),
              disabledForegroundColor: textColor.withOpacity(0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              padding: widget.padding,
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
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
