import 'package:expence_tracker/shared/widgets/app_button.dart';
import 'package:expence_tracker/transections/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/data/firebase_provider.dart';
import '../../../shared/widgets/custom_toast.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late FirebaseProvider provider;
  @override
  void initState() {
    super.initState();
    provider = context.read<FirebaseProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadUnsyncedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sync Data", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Selector<FirebaseProvider, (bool, List<ExpenseModel>)>(
        selector: (context, provider) => (provider.isLoading || provider.toServer, provider.unsyncedTransactions),
        shouldRebuild: (prev, next) => prev != next,
        builder: (context, data, child) {
          final (isLoading, unsyncedTransactions) = data;
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), SizedBox(height: 10), Text("Syncing...")],
              ),
            );
          }

          if (unsyncedTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done_rounded, size: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text("All data is synced with cloud", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [Text("Unsynced: ${unsyncedTransactions.length}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: unsyncedTransactions.length,
                  itemBuilder: (context, index) {
                    final item = unsyncedTransactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 20),
                        ),
                        title: Text(item.title ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("₹${item.amount}"),
                        trailing: Text(
                          item.date != null ? "${item.date!.day}/${item.date!.month}" : "",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: AppButton(
                  label: "Sync Now",
                  icon: Icons.sync_rounded,
                  onPressed: () async {
                    final msg = await provider.syncAllData();
                    if (context.mounted) {
                      CustomeToast.showSuccess(context, msg);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
