import 'package:expence_tracker/shared/data/shared_pref_data.dart';
import 'package:expence_tracker/shared/utils/category_utils.dart';
import 'package:expence_tracker/shared/widgets/summary_card.dart';
import 'package:expence_tracker/shared/widgets/transaction_item_tile.dart';
import 'package:expence_tracker/transections/controller/transaction_provider.dart';
import 'package:expence_tracker/transections/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'expenses_screen.dart';

import 'package:expence_tracker/shared/data/firebase_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
            // 1. Selector for User Name only
            Selector<FirebaseProvider, String>(
              selector: (context, provider) => provider.userData?['name'] ?? "User",
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
              // 2. Selector for the Balance Card (Calculates balance and trend)
              Selector<TransactionProvider, Map<String, double>>(
                selector: (context, provider) {
                  final totalIncome = provider.incomes.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0));
                  final totalExpense = provider.expenses.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0));
                  final balance = double.parse(AppPref.getInitMoney()) + totalIncome - totalExpense;

                  // Trend Calculation Logic
                  final now = DateTime.now();
                  final startOfThisMonth = DateTime(now.year, now.month, 1);
                  final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

                  final thisMonthBal = provider.allTransactions
                      .where((t) => t.date != null && t.date!.isAfter(startOfThisMonth))
                      .fold(0.0, (sum, t) => sum + (t.type == "income" ? (t.amount ?? 0) : -(t.amount ?? 0)));

                  final lastMonthBal = provider.allTransactions
                      .where((t) => t.date != null && t.date!.isAfter(startOfLastMonth) && t.date!.isBefore(startOfThisMonth))
                      .fold(0.0, (sum, t) => sum + (t.type == "income" ? (t.amount ?? 0) : -(t.amount ?? 0)));

                  double trend = 0.0;
                  if (lastMonthBal != 0) {
                    trend = ((thisMonthBal - lastMonthBal) / lastMonthBal.abs()) * 100;
                  } else if (thisMonthBal != 0) {
                    trend = 100.0;
                  }

                  return {'balance': balance, 'trend': trend};
                },
                builder: (context, data, child) {
                  return _buildBalanceCard(context, data['balance']!, data['trend']!);
                },
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  // 3. Selector for Income Summary Card
                  Expanded(
                    child: Selector<TransactionProvider, double>(
                      selector: (context, provider) => provider.incomes.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0)),
                      builder: (context, totalIncome, child) {
                        return SummaryCard(
                          title: "Income",
                          amount: totalIncome,
                          icon: Icons.arrow_downward,
                          color: Colors.greenAccent[400]!,
                          onTap: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpensesScreen(isIncome: true, newScreen: true))),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 4. Selector for Expense Summary Card
                  Expanded(
                    child: Selector<TransactionProvider, double>(
                      selector: (context, provider) => provider.expenses.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0)),
                      builder: (context, totalExpense, child) {
                        return SummaryCard(
                          title: "Expenses",
                          amount: totalExpense,
                          icon: Icons.arrow_upward,
                          color: Colors.orangeAccent[400]!,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ExpensesScreen(isIncome: false, newScreen: true)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => context.read<TransactionProvider>().setIndex(1),
                    child: Text(
                      "See All",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // 5. Selector for Recent Transactions List (Limits to top 3)
              Selector<TransactionProvider, List<ExpenseModel>>(
                selector: (context, provider) => provider.allTransactions.take(3).toList(),
                builder: (context, recentTransactions, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, index) {
                      final item = recentTransactions[index];
                      return TransactionItemTile(item: item, icon: CategoryUtils.getIconForCategory(item.category), isIncome: item.type == "income");
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
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
              // Trend Badge
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
          // Formatted Currency
          Text(
            "₹${NumberFormat("#,##,###.##").format(balance)}",
            style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
        ],
      ),
    );
  }
}
