import 'package:expence_tracker/transections/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_card.dart';

class TransactionItemTile extends StatelessWidget {
  final ExpenseModel item;
  final IconData icon;
  final bool isIncome;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionItemTile({super.key, required this.item, required this.icon, required this.isIncome, this.onDelete, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActions = onDelete != null || onEdit != null;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Category Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.greenAccent : Colors.orangeAccent).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isIncome ? Colors.greenAccent[400] : Colors.orangeAccent[400], size: 24),
          ),
          const SizedBox(width: 14),

          // Title, Category & Note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? "Transaction",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      item.category ?? "General",
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.circle, size: 4, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.2)),
                      ),
                      Expanded(
                        child: Text(
                          item.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Amount, Date & Menu
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncome ? "+" : "-"}₹${item.amount?.toStringAsFixed(2)}",
                    style: TextStyle(color: isIncome ? Colors.greenAccent[400] : Colors.orangeAccent[400], fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    item.date != null ? DateFormat('MMM dd').format(item.date!) : "",
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4), fontSize: 10),
                  ),
                ],
              ),
              if (hasActions)
                PopupMenuButton<String>(
                  elevation: 8,
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4)),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18, color: theme.primaryColor),
                          const SizedBox(width: 10),
                          const Text("Edit", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          const Text("Delete", style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
