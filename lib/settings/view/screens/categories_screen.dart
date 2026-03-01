import 'package:expence_tracker/shared/widgets/app_action_card.dart';
import 'package:expence_tracker/shared/widgets/app_editable_list_tile.dart';
import '../../../shared/widgets/one_line_dialog.dart';
import '../../controller/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final expenseCategories = provider.expenseCategories;
    final incomeCategories = provider.incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Labels", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Expense Categories".toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              ...expenseCategories.map(
                (name) => AppEditableListTile(
                  title: name,
                  onEdit: () {
                    oneLineDialogBox(
                      context: context,
                      title: "Edit Category",
                      hintText: "Category name",
                      buttonText: "Save",
                      editText: name,
                      onPressed: (value) => provider.updateCategory(oldName: name, newName: value, type: "expense"),
                    );
                  },
                  onDelete: () => provider.removeExpenseCategory(name),
                ),
              ),
              AppActionCard(
                label: "Add Expense Label",
                onTap: () {
                  oneLineDialogBox(
                    context: context,
                    title: "Add Expense Label",
                    hintText: "Category name",
                    buttonText: "Add",
                    onPressed: (value) => provider.addExpenseCategory(value),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                "Income Categories".toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              ...incomeCategories.map(
                (name) => AppEditableListTile(
                  title: name,
                  onEdit: () {
                    oneLineDialogBox(
                      context: context,
                      title: "Edit Category",
                      hintText: "Category name",
                      buttonText: "Save",
                      editText: name,
                      onPressed: (value) => provider.updateCategory(oldName: name, newName: value, type: "income"),
                    );
                  },
                  onDelete: () => provider.removeIncomeCategory(name),
                ),
              ),
              AppActionCard(
                label: "Add Income Label",
                onTap: () {
                  oneLineDialogBox(
                    context: context,
                    title: "Add Income Label",
                    hintText: "Category name",
                    buttonText: "Add",
                    onPressed: (value) => provider.addIncomeCategory(value),
                  );
                },
              ),
              const SizedBox(height: 30),
              Text(
                "Payment Methods".toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              ...provider.paymentMethods.map(
                (name) => AppEditableListTile(
                  title: name,
                  onEdit: () {
                    oneLineDialogBox(
                      context: context,
                      title: "Edit Method",
                      hintText: "Method name",
                      buttonText: "Save",
                      editText: name,
                      onPressed: (value) => provider.updatePaymentMethod(oldName: name, newName: value),
                    );
                  },
                  onDelete: () => provider.removePaymentMethod(name),
                ),
              ),
              AppActionCard(
                label: "Add Payment Method",
                onTap: () {
                  oneLineDialogBox(
                    context: context,
                    title: "Add Payment Method",
                    hintText: "Method name",
                    buttonText: "Add",
                    onPressed: (value) => provider.addPaymentMethod(value),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
