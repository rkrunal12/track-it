import 'dart:developer';
import 'package:expence_tracker/shared/data/firebase_provider.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../database/daos/categories_dao.dart';
import '../../database/daos/payment_methods_dao.dart';
import '../../shared/data/shared_pref_data.dart';
import '../../shared/widgets/one_line_dialog.dart';

class SettingsProvider with ChangeNotifier {
  CategoriesDao categoriesDao;
  PaymentMethodsDao paymentMethodsDao;

  SettingsProvider(this.categoriesDao, this.paymentMethodsDao);

  List<String> expenseCategories = [];
  List<String> incomeCategories = [];

  // =============== LOAD CATEGORIES =================
  Future<void> setExpense() async {
    log("setExpense Called");
    final userId = AppPref.getUid();
    final result = await categoriesDao.getCategoriesByType('expense', userId);

    if (result.isEmpty) {
      await categoriesDao.insertCategory(
        CategoriesCompanion(name: drift.Value("Medical"), type: drift.Value("expense"), userId: drift.Value(userId)),
      );
      await categoriesDao.insertCategory(CategoriesCompanion(name: drift.Value("Food"), type: drift.Value("expense"), userId: drift.Value(userId)));
      await setExpense();
    } else {
      expenseCategories = result.map((e) => e.name).toList();
      notifyListeners();
    }
  }

  Future<void> setIncome() async {
    log("setIncome Called");
    final userId = AppPref.getUid();
    final result = await categoriesDao.getCategoriesByType('income', userId);

    if (result.isEmpty) {
      await categoriesDao.insertCategory(CategoriesCompanion(name: drift.Value("Salary"), type: drift.Value("income"), userId: drift.Value(userId)));
      await categoriesDao.insertCategory(CategoriesCompanion(name: drift.Value("Gift"), type: drift.Value("income"), userId: drift.Value(userId)));
      await setIncome();
    } else {
      incomeCategories = result.map((e) => e.name).toList();
      notifyListeners();
    }
  }

  // =============== CATEGORY ACTIONS =================
  Future<void> addExpenseCategory(String value) async {
    final userId = AppPref.getUid();
    await categoriesDao.insertCategory(CategoriesCompanion(name: drift.Value(value), type: drift.Value("expense"), userId: drift.Value(userId)));
    await setExpense();
  }

  Future<void> addIncomeCategory(String value) async {
    final userId = AppPref.getUid();
    await categoriesDao.insertCategory(CategoriesCompanion(name: drift.Value(value), type: drift.Value("income"), userId: drift.Value(userId)));
    await setIncome();
  }

  Future<void> removeExpenseCategory(String name) async {
    final userId = AppPref.getUid();
    await categoriesDao.deleteCategory(name, "expense", userId);
    await setExpense();
  }

  Future<void> removeIncomeCategory(String name) async {
    final userId = AppPref.getUid();
    await categoriesDao.deleteCategory(name, "income", userId);
    await setIncome();
  }

  Future<void> updateCategory({required String oldName, required String newName, required String type}) async {
    final userId = AppPref.getUid();
    await categoriesDao.updateCategory(oldName, type, userId, CategoriesCompanion(name: drift.Value(newName)));
    if (type == "expense") {
      await setExpense();
    } else {
      await setIncome();
    }
  }

  // =============== PAYMENT METHODS =================
  List<String> paymentMethods = [];

  Future<void> setPayment() async {
    final userId = AppPref.getUid();
    final result = await paymentMethodsDao.getAllPaymentMethods(userId);
    if (result.isEmpty) {
      await paymentMethodsDao.insertPaymentMethod(PaymentMethodsCompanion(name: drift.Value("Cash"), userId: drift.Value(userId)));
      await paymentMethodsDao.insertPaymentMethod(PaymentMethodsCompanion(name: drift.Value("Card"), userId: drift.Value(userId)));
      await setPayment();
    } else {
      paymentMethods = result.map((e) => e.name).toList();
      notifyListeners();
    }
  }

  Future<void> addPaymentMethod(String value) async {
    final userId = AppPref.getUid();
    await paymentMethodsDao.insertPaymentMethod(PaymentMethodsCompanion(name: drift.Value(value), userId: drift.Value(userId)));
    await setPayment();
  }

  Future<void> removePaymentMethod(String name) async {
    final userId = AppPref.getUid();
    await paymentMethodsDao.deletePaymentMethod(name, userId);
    await setPayment();
  }

  Future<void> updatePaymentMethod({required String oldName, required String newName}) async {
    final userId = AppPref.getUid();
    await paymentMethodsDao.updatePaymentMethod(oldName, userId, PaymentMethodsCompanion(name: drift.Value(newName)));
    await setPayment();
  }

  // =============== PURSE / BALANCE =================
  double initPurse = 0;

  void getInitPurse() {
    String money = AppPref.getInitMoney();
    initPurse = double.tryParse(money) ?? 0;
    notifyListeners();
  }

  Future<void> setInitPurse(BuildContext context, String value) async {
    AppPref.setInitMoney(value);
    AppPref.setIsInitPeruse(true);
    initPurse = double.tryParse(value) ?? 0;
    notifyListeners();

    // Sync to Firebase
    await Provider.of<FirebaseProvider>(context, listen: false).setInitialBalance(initPurse);
  }

  // =============== INITIALIZATION =================
  Future<void> initSettings(BuildContext context) async {
    // 1. Fetch user profile (includes balance)
    await Provider.of<FirebaseProvider>(context, listen: false).fetchUserProfile();

    // 2. Load lists
    await setExpense();
    await setIncome();
    getInitPurse();
    await setPayment();

    // 3. Prompt for purse if not set in shared pref (and not found on server)
    if (!AppPref.getIsInitPeruse()) {
      if (context.mounted) {
        oneLineDialogBox(
          context: context,
          title: "Setup Wallet",
          hintText: "Enter starting balance (e.g. 5000)",
          buttonText: "Get Started",
          onPressed: (value) async {
            await setInitPurse(context, value);
          },
        );
      }
    }
  }

  List<DropdownMenuItem<String>> buildDropdown(List<String> items) {
    return items.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList();
  }
}
