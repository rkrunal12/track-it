import 'package:flutter/material.dart';
import 'app_card.dart';

/// A professional list tile with edit and delete actions.
class AppEditableListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppEditableListTile({super.key, required this.title, this.subtitle, this.leadingIcon, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          if (leadingIcon != null) ...[Icon(leadingIcon, color: theme.primaryColor, size: 22), const SizedBox(width: 16)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                ),
                if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.primaryColor, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
