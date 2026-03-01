import 'package:expence_tracker/settings/controller/settings_provider.dart';
import 'package:expence_tracker/shared/utils/category_utils.dart';
import 'package:expence_tracker/shared/widgets/summary_card.dart';
import 'package:expence_tracker/shared/widgets/transaction_item_tile.dart';
import 'package:expence_tracker/transections/controller/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'expenses_screen.dart';

import 'package:expence_tracker/shared/data/firebase_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, SettingsProvider>(
      builder: (context, transactionProvider, settingsProvider,child) {
        final income = transactionProvider.incomes;
        final expense = transactionProvider.expenses;
        final totalIncome = income.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0));
        final totalExpense = expense.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0));
        final balance =  totalIncome - totalExpense;

        final now = DateTime.now();
        final startOfThisMonth = DateTime(now.year, now.month, 1);
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

        final thisMonthTransactions = transactionProvider.allTransactions.where((t) => t.date != null && t.date!.isAfter(startOfThisMonth)).toList();
        final lastMonthTransactions = transactionProvider.allTransactions
            .where((t) => t.date != null && t.date!.isAfter(startOfLastMonth) && t.date!.isBefore(startOfThisMonth))
            .toList();

        final thisMonthBalance = thisMonthTransactions.fold(0.0, (sum, t) => sum + (t.type == "income" ? (t.amount ?? 0) : -(t.amount ?? 0)));
        final lastMonthBalance = lastMonthTransactions.fold(0.0, (sum, t) => sum + (t.type == "income" ? (t.amount ?? 0) : -(t.amount ?? 0)));

        double trendPercentage = 0.0;
        if (lastMonthBalance != 0) {
          trendPercentage = ((thisMonthBalance - lastMonthBalance) / lastMonthBalance.abs()) * 100;
        } else if (thisMonthBalance != 0) {
          trendPercentage = 100.0;
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back,", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
                Selector<FirebaseProvider, String>(
                  selector: (context, provider) => provider.userData?['name'] ?? "User",
                  shouldRebuild: (previous, next) => previous != next,
                  builder: (context, userName, child) {
                    return Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
                  },
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(context, balance, trendPercentage),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: "Income",
                          amount: totalIncome,
                          icon: Icons.arrow_downward,
                          color: Colors.greenAccent[400]!,
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpensesScreen(isIncome: true, newScreen: true))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SummaryCard(
                          title: "Expenses",
                          amount: totalExpense,
                          icon: Icons.arrow_upward,
                          color: Colors.orangeAccent[400]!,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ExpensesScreen(isIncome: false, newScreen: true)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Transactions", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => transactionProvider.setIndex(1),
                        child: Text(
                          "See All",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactionProvider.allTransactions.length > 3 ? 3 : transactionProvider.allTransactions.length,
                    itemBuilder: (context, index) {
                      final item = transactionProvider.allTransactions[index];
                      return TransactionItemTile(item: item, icon: CategoryUtils.getIconForCategory(item.category), isIncome: item.type == "income");
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, double trendPercentage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Balance",
                style: TextStyle(
                  color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendPercentage >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: trendPercentage >= 0 ? Colors.greenAccent : Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${trendPercentage >= 0 ? "+" : ""}${trendPercentage.toStringAsFixed(1)}%",
                      style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "₹${NumberFormat("#,##,###.##").format(balance)}",
            style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
        ],
      ),
    );
  }
}
