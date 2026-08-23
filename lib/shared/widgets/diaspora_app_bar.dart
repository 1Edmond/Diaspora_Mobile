import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/design_system.dart';

class DiasporaAppBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final Widget? leading;

  const DiasporaAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 56,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.72),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (showBackButton)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.getTextMain(context),
                  ),
                  onPressed: onBackPressed ??
                      () {
                        try {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        } catch (_) {
                          context.go('/home');
                        }
                      },
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
              const Spacer(),
              trailing ?? const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
