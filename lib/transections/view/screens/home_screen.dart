import 'package:expence_tracker/transections/view/screens/dashboard_page.dart';
import 'package:expence_tracker/transections/view/screens/expenses_screen.dart';
import 'package:expence_tracker/settings/view/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence_tracker/shared/data/firebase_provider.dart';
import 'package:expence_tracker/settings/controller/settings_provider.dart';
import 'package:expence_tracker/transections/controller/transaction_provider.dart';

import '../widgets/add_transaction_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

      await settingsProvider.initSettings(context);
      await firebaseProvider.fetchFromServer();
      if (mounted) {
        transactionProvider.initTransaction();
        firebaseProvider.fetchUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, FirebaseProvider>(
      builder: (context, transactionProvider, firebaseProvider, child) {
        return Scaffold(
          body: firebaseProvider.isLoading ? const Center(child: CircularProgressIndicator()) : _buildScreen(transactionProvider.index),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            height: 75,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, Icons.grid_view_rounded, "Home", transactionProvider),
                _navItem(context, 1, Icons.analytics_outlined, "Stats", transactionProvider),
                _navItem(context, 2, Icons.person_outline_rounded, "Profile", transactionProvider),
              ],
            ),
          ),
          floatingActionButton: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const AddTransactionSheet(),
              );
            },
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        );
      },
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, String label, TransactionProvider provider) {
    final isSelected = provider.index == index;
    final color = isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.4);

    return InkWell(
      onTap: () => provider.setIndex(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(int index) {
    return [const DashboardPage(), const ExpensesScreen(), const SettingsScreen()][index];
  }
}
