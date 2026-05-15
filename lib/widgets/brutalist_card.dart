import 'package:flutter/material.dart';
import '../utils/brutalist_theme.dart';

class BrutalistCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Offset? shadowOffset;
  final Color? shadowColor;
  final double borderRadius;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 3,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.all(0),
    this.onTap,
    this.shadowOffset,
    this.shadowColor,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultShadow = isDark ? AppColors.white : AppColors.black;
    final offset = shadowOffset ?? const Offset(4, 4);

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardTheme.color,
        border: Border.all(
          color: borderColor ?? (isDark ? AppColors.white : AppColors.black),
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(offset: offset, color: shadowColor ?? defaultShadow),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    return card;
  }
}
