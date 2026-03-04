import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:expence_tracker/shared/utils/category_utils.dart';
import 'package:expence_tracker/shared/widgets/custom_numpad.dart';
import 'package:expence_tracker/shared/widgets/app_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../controller/transaction_provider.dart';
import '../../../settings/controller/settings_provider.dart';
import '../../model/expense_model.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final TextEditingController _amountController = TextEditingController(text: "0");
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize default payment method if not set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (transactionProvider.selectedPaymentMethod == null && settingsProvider.paymentMethods.isNotEmpty) {
        transactionProvider.setPaymentMethod(settingsProvider.paymentMethods.first);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPress(String value) {
    setState(() {
      if (value == "back") {
        if (_amountController.text.length > 1) {
          _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
        } else {
          _amountController.text = "0";
        }
      } else if (value == ".") {
        if (!_amountController.text.contains(".")) {
          _amountController.text += ".";
        }
      } else {
        if (_amountController.text == "0") {
          _amountController.text = value;
        } else if (_amountController.text.length < 10) {
          _amountController.text += value;
        }
      }
    });
  }

  void _showAllCategoriesDialog(List<String> categories, TransactionProvider transactionProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Select Category"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () {
                  transactionProvider.setCategory(cat);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CategoryUtils.getIconForCategory(cat), color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(height: 4),
                      Text(cat, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categories = transactionProvider.typeOfTransaction == 0 ? settingsProvider.expenseCategories : settingsProvider.incomeCategories;

    // Move selected category to the first place ONLY if it's not in the first 4 categories
    List<String> displayCategories = List<String>.from(categories);
    final selectedCat = transactionProvider.selectedCategory;

    if (selectedCat != null) {
      int originalIndex = categories.indexOf(selectedCat);
      if (originalIndex > 3) {
        displayCategories.remove(selectedCat);
        displayCategories.insert(0, selectedCat);
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          // Glass Background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 12),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Custom Toggle for Expense/Income
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _expandedToggleItem(0, "Expense", const Color(0xFFFF5252), transactionProvider),
                      _expandedToggleItem(1, "Income", const Color(0xFF00E676), transactionProvider),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Amount Entry Section (Visual display for amount)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      "Amount",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "₹",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: transactionProvider.typeOfTransaction == 0 ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _amountController.text,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: transactionProvider.typeOfTransaction == 0 ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Note Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomTextField(controller: _noteController, hintText: "Add a note..."),
              ),

              const SizedBox(height: 15),

              // Category Horizontal Selector
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: displayCategories.length > 4 ? 5 : displayCategories.length,
                  itemBuilder: (context, index) {
                    if (index == 4 && displayCategories.length > 4) {
                      return _buildSeeAllItem(displayCategories, transactionProvider);
                    }
                    final cat = displayCategories[index];
                    final isSelected = transactionProvider.selectedCategory == cat;
                    return _buildCategoryChip(cat, isSelected, transactionProvider);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Payment Method Selector
              Visibility(
                visible: transactionProvider.typeOfTransaction == 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 8),
                        child: Text(
                          "Payment Method",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(180),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: settingsProvider.paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = settingsProvider.paymentMethods[index];
                            final isSelected = transactionProvider.selectedPaymentMethod == method;
                            return GestureDetector(
                              onTap: () => transactionProvider.setPaymentMethod(method),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? Colors.white.withAlpha(50) : Colors.transparent),
                                ),
                                child: Text(
                                  method,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Custom Numpad
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: CustomNumpad(onKeyPress: _onKeyPress),
                ),
              ),

              // Final Action Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: AppButton(label: "Record Transaction", onPressed: () => _saveTransaction(transactionProvider)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String cat, bool isSelected, TransactionProvider transactionProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => transactionProvider.setCategory(cat),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CategoryUtils.getIconForCategory(cat),
              color: isSelected ? (isDark ? Colors.black : Colors.white) : theme.textTheme.bodySmall?.color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              cat,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isSelected ? (isDark ? Colors.black : Colors.white) : theme.textTheme.bodyMedium?.color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeAllItem(List<String> categories, TransactionProvider transactionProvider) {
    return GestureDetector(
      onTap: () => _showAllCategoriesDialog(categories, transactionProvider),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.more_horiz_rounded, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              "See All",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expandedToggleItem(int type, String label, Color activeColor, TransactionProvider transactionProvider) {
    final isSelected = transactionProvider.typeOfTransaction == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          transactionProvider.setTypeOfTransaction(type);
          transactionProvider.setCategory(null);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: isSelected ? activeColor : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? (isDark ? Colors.black : Colors.white) : Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _saveTransaction(TransactionProvider transactionProvider) {
    final amountText = _amountController.text;
    final noteText = _noteController.text;

    if (amountText == "0" || amountText.isEmpty || transactionProvider.selectedCategory == null) return;

    final selectedMethod = transactionProvider.selectedPaymentMethod ?? "Cash";

    transactionProvider.addTransaction(
      ExpenseModel(
        title: noteText.isEmpty ? transactionProvider.selectedCategory : noteText,
        amount: double.tryParse(amountText) ?? 0,
        date: DateTime.now(),
        type: transactionProvider.typeOfTransaction == 0 ? "expense" : "income",
        category: transactionProvider.selectedCategory,
        paymentMethod: selectedMethod,
        note: noteText,
      ),
    );

    Navigator.pop(context);
  }
}
