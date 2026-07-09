import 'package:diaspora_app/core/theme/design_system.dart';
import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPressed;
  final Color? color;

  final VoidCallback? onTap;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.isPressed = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color:
              color ??
              (isDark ? AppColors.backgroundDark : AppColors.background),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:
              isPressed
                  ? AppShadows.neumorphicInvert(isDark: isDark)
                  : AppShadows.neumorphic(isDark: isDark),
        ),
        child: child,
      ),
    );
  }
}
