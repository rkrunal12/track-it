import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_card.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SummaryCard({super.key, required this.title, required this.amount, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Text("₹${NumberFormat("#,##,###").format(amount)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
