import 'package:flutter/material.dart';
import 'app_card.dart';

/// A professional action card (previously StandardAddButton).
class AppActionCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;

  const AppActionCard({super.key, required this.label, required this.onTap, this.icon = Icons.add_circle_outline_rounded, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: iconColor ?? theme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
