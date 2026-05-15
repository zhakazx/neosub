import 'package:flutter/material.dart';
import '../utils/brutalist_theme.dart';

enum BrutalistButtonVariant { primary, secondary, danger, warning, success }

class BrutalistButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final BrutalistButtonVariant variant;
  final IconData? icon;
  final double? width;

  const BrutalistButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BrutalistButtonVariant.primary,
    this.icon,
    this.width,
  });

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _pressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _pressed = false);
      widget.onPressed!.call();
    }
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor = isDark ? AppColors.white : AppColors.black;
    final borderColor = isDark ? AppColors.white : AppColors.black;

    Color bgColor;
    Color fgColor;

    switch (widget.variant) {
      case BrutalistButtonVariant.primary:
        bgColor = AppColors.purple;
        fgColor = AppColors.white;
      case BrutalistButtonVariant.secondary:
        bgColor = isDark ? AppColors.darkGrey : AppColors.white;
        fgColor = isDark ? AppColors.white : AppColors.black;
      case BrutalistButtonVariant.danger:
        bgColor = AppColors.pink;
        fgColor = AppColors.white;
      case BrutalistButtonVariant.warning:
        bgColor = AppColors.yellow;
        fgColor = AppColors.black;
      case BrutalistButtonVariant.success:
        bgColor = AppColors.teal;
        fgColor = AppColors.black;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.linear,
        width: widget.width,
        transform: _pressed
            ? (Matrix4.identity()..translate(4.0, 4.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: widget.variant == BrutalistButtonVariant.secondary
                ? borderColor
                : borderColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              offset: Offset(_pressed ? 0 : 4, _pressed ? 0 : 4),
              color: widget.variant == BrutalistButtonVariant.primary
                  ? AppColors.purpleDark
                  : widget.variant == BrutalistButtonVariant.danger
                  ? AppColors.pink.withValues(alpha: 0.5)
                  : widget.variant == BrutalistButtonVariant.warning
                  ? AppColors.yellowDark
                  : widget.variant == BrutalistButtonVariant.success
                  ? AppColors.greenDark
                  : shadowColor,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label.toUpperCase(),
              style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
                color: fgColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
