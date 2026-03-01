import 'package:flutter/material.dart';

/// A standardized card base for consistent styling across the app.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AppCard({super.key, required this.child, this.padding, this.margin, this.borderRadius = 16.0, this.color, this.border, this.boxShadow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: boxShadow ?? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
