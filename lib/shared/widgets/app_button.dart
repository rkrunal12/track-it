import 'package:flutter/material.dart';

/// A premium, gradient-based universal button for the entire project.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56.0,
    this.borderRadius = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onPressed == null ? 0.6 : 1.0,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [if (onPressed != null) BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: isLoading
              ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
                    Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
        ),
      ),
    );
  }
}
