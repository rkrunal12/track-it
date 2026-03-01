import 'dart:developer';
import 'package:expence_tracker/settings/controller/settings_provider.dart';
import 'package:expence_tracker/transections/controller/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';
import '../../../shared/widgets/app_button.dart';
import '../../model/expense_model.dart';

class AddDialogBox extends StatefulWidget {
  final String type;
  final ExpenseModel? model;

  const AddDialogBox({super.key, required this.type, this.model});

  @override
  State<AddDialogBox> createState() => _AddDialogBoxState();
}

class _AddDialogBoxState extends State<AddDialogBox> {
  final title = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.model != null) {
      title.text = widget.model!.title ?? "";
      amount.text = widget.model!.amount?.toString() ?? "0";
      note.text = widget.model!.note ?? "";

      // SAFE provider update after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        provider.setCategory(widget.model!.category);
        provider.setPaymentMethod(widget.model!.paymentMethod);
        provider.setTitle(widget.model!.title ?? "");
        provider.setAmount(widget.model!.amount?.toString() ?? "0");
        provider.setNote(widget.model!.note ?? "");
      });
    } else {
      // Clear provider state for new entry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        provider.setCategory(null);
        provider.setPaymentMethod(null);
        provider.setTitle("");
        provider.setAmount("");
        provider.setNote("");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Type ${widget.type}");

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Consumer2<TransactionProvider, SettingsProvider>(
            builder: (context, transactionProvider, settingsProvider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          widget.model == null
                              ? "Add ${widget.type == "income" ? "Income" : "Expense"}"
                              : "Edit ${widget.type == "income" ? "Income" : "Expense"}",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: title,
                      hintText: "Title",
                      onChanged: transactionProvider.setTitle,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: amount,
                      hintText: "Amount",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: transactionProvider.setAmount,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter an amount';
                        if (double.tryParse(value) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown(
                      value: transactionProvider.selectedCategory,
                      list: settingsProvider.buildDropdown(
                        widget.type == "income" ? settingsProvider.incomeCategories : settingsProvider.expenseCategories,
                      ),
                      type: "Category",
                      onChanged: transactionProvider.setCategory,
                    ),
                    const SizedBox(height: 12),
                    CustomDropdown(
                      value: transactionProvider.selectedPaymentMethod,
                      list: settingsProvider.buildDropdown(settingsProvider.paymentMethods),
                      type: "Payment Method",
                      onChanged: transactionProvider.setPaymentMethod,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: note,
                      hintText: "Note",
                      onChanged: transactionProvider.setNote,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a note' : null,
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: widget.model == null
                          ? "Add ${widget.type == "income" ? "Income" : "Expense"}"
                          : "Update ${widget.type == "income" ? "Income" : "Expense"}",
                      onPressed: transactionProvider.isFormValid()
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                if (widget.model == null) {
                                  // ADD NEW
                                  transactionProvider.addTransaction(
                                    ExpenseModel(
                                      title: title.text,
                                      amount: double.tryParse(amount.text),
                                      note: note.text,
                                      type: widget.type,
                                      category: transactionProvider.selectedCategory,
                                      paymentMethod: transactionProvider.selectedPaymentMethod,
                                    ),
                                  );
                                } else {
                                  // UPDATE
                                  transactionProvider.updateTransaction(
                                    ExpenseModel(
                                      id: widget.model!.id,
                                      title: title.text,
                                      amount: double.tryParse(amount.text),
                                      note: note.text,
                                      type: widget.type,
                                      category: transactionProvider.selectedCategory,
                                      paymentMethod: transactionProvider.selectedPaymentMethod,
                                      date: widget.model!.date,
                                    ),
                                  );
                                }

                                Navigator.pop(context);
                              }
                            }
                          : null,
                      borderRadius: 12,
                      height: 48,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
