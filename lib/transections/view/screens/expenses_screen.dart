import 'package:expence_tracker/shared/utils/category_utils.dart';
import 'package:expence_tracker/shared/widgets/transaction_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:expence_tracker/transections/controller/transaction_provider.dart';
import 'package:expence_tracker/settings/controller/settings_provider.dart';
import '../../model/expense_model.dart';
import '../widgets/add_dialog_box.dart';

class ExpensesScreen extends StatefulWidget {
  final bool? isIncome;
  final bool newScreen;

  const ExpensesScreen({super.key, this.isIncome, this.newScreen = false});

  @override
  State<ExpensesScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpensesScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: Drawer(child: _buildFilterDrawer(context)),
      appBar: AppBar(
        title: const Text("Transactions"),
        leading: widget.newScreen ? const BackButton() : const SizedBox.shrink(),
        actions: [
          Builder(
            builder: (ctx) => IconButton(onPressed: () => Scaffold.of(ctx).openDrawer(), icon: const Icon(Icons.filter_list_rounded)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (val) => context.read<TransactionProvider>().setSearchQuery(val),
              decoration: InputDecoration(
                hintText: "Search transactions...",
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          searchController.clear();
                          context.read<TransactionProvider>().setSearchQuery("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          Expanded(
            child: Selector<TransactionProvider, Map<String, List<ExpenseModel>>>(
              selector: (context, provider) => provider.getGroupedTransactions(isIncome: widget.isIncome),
              builder: (context, groupedData, child) {
                if (groupedData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[800]),
                        const SizedBox(height: 16),
                        const Text("No Transactions Found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                // Flatten the grouped data into a single list for reliable indexing
                final List<dynamic> flatList = [];
                groupedData.forEach((category, transactions) {
                  flatList.add(category); // Add Header
                  flatList.addAll(transactions); // Add Items
                });

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: !widget.newScreen ? 16 : 8, vertical: 10),
                  itemCount: flatList.length,
                  itemBuilder: (context, index) {
                    final item = flatList[index];

                    if (item is String) {
                      // Category Header
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
                        child: Row(
                          children: [
                            Icon(CategoryUtils.getIconForCategory(item), size: 18, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              item,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      );
                    }

                    // Transaction Item
                    final tx = item as ExpenseModel;
                    return TransactionItemTile(
                      item: tx,
                      icon: CategoryUtils.getIconForCategory(tx.category),
                      isIncome: tx.type == "income",
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AddDialogBox(type: tx.type == "income" ? "income" : "expense", model: tx),
                        );
                      },
                      onDelete: () => context.read<TransactionProvider>().removeTransaction(tx.id!),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Consumer2<TransactionProvider, SettingsProvider>(
          builder: (context, transactionProvider, settingsProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filter & Sort", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Range Picker Action
                        ListTile(
                          leading: const Icon(Icons.date_range_rounded),
                          title: const Text("Date Range", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            transactionProvider.dateRange == null
                                ? "All Time"
                                : "${DateFormat('MMM dd').format(transactionProvider.dateRange!.start)} - ${DateFormat('MMM dd').format(transactionProvider.dateRange!.end)}",
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: transactionProvider.dateRange,
                            );
                            if (picked != null) {
                              transactionProvider.setDateRange(picked);
                            }
                          },
                        ),

                        // Amount Range Slider
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Amount range", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              RangeSlider(
                                values:
                                    transactionProvider.amountRange ??
                                    RangeValues(transactionProvider.getMinAmount(), transactionProvider.getMaxAmount()),
                                min: transactionProvider.getMinAmount(),
                                max: transactionProvider.getMaxAmount(),
                                divisions: 20,
                                labels: RangeLabels(
                                  (transactionProvider.amountRange?.start ?? transactionProvider.getMinAmount()).round().toString(),
                                  (transactionProvider.amountRange?.end ?? transactionProvider.getMaxAmount()).round().toString(),
                                ),
                                onChanged: (val) => transactionProvider.setAmountRange(val),
                              ),
                            ],
                          ),
                        ),

                        // Category Filter Section
                        _buildFilterSection(
                          context,
                          title: "Categories",
                          children: [
                            if (widget.isIncome != false) ...[
                              ...settingsProvider.incomeCategories.map(
                                (cat) => _filterChip(
                                  context,
                                  cat,
                                  isSelected: transactionProvider.cate.contains(cat),
                                  onTap: () => transactionProvider.addToCate(cat),
                                ),
                              ),
                            ],
                            if (widget.isIncome != true) ...[
                              ...settingsProvider.expenseCategories.map(
                                (cat) => _filterChip(
                                  context,
                                  cat,
                                  isSelected: transactionProvider.cate.contains(cat),
                                  onTap: () => transactionProvider.addToCate(cat),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Payment Method Filter Section
                        _buildFilterSection(
                          context,
                          title: "Payment Methods",
                          children: settingsProvider.paymentMethods.map((method) {
                            return _filterChip(
                              context,
                              method,
                              isSelected: transactionProvider.method.contains(method),
                              onTap: () => transactionProvider.addToMethod(method),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        transactionProvider.setFilterIndex(null);
                        transactionProvider.setDateRange(null);
                        transactionProvider.setAmountRange(null);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), elevation: 0),
                      child: const Text(
                        "Reset All",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String text, {required bool isSelected, required VoidCallback onTap}) {
    return FilterChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
