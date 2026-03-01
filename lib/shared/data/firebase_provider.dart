import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expence_tracker/shared/utils/internet_connection.dart';
import '../../transections/model/expense_model.dart';
import '../../database/daos/transactions_dao.dart';
import '../../database/daos/categories_dao.dart';
import '../../database/daos/payment_methods_dao.dart';
import '../../database/database.dart';
import 'package:drift/drift.dart' as drift;
import '../../shared/data/shared_pref_data.dart';

class FirebaseProvider with ChangeNotifier {
  final TransactionDao transactionDao;
  final CategoriesDao categoriesDao;
  final PaymentMethodsDao paymentMethodsDao;
  final AppDatabase db;

  FirebaseProvider(this.transactionDao, this.categoriesDao, this.paymentMethodsDao, this.db);

  bool toServer = false;
  double? initialBalance;

  bool isLoading = false;
  List<ExpenseModel> unsyncedTransactions = [];
  Map<String, dynamic>? userData;

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (doc.exists) {
        userData = doc.data();
        if (userData?['initialBalance'] != null && userData?['initialBalance'] != 0) {
          initialBalance = (userData!['initialBalance'] as num).toDouble();
          AppPref.setInitMoney(initialBalance.toString());
          AppPref.setIsInitPeruse(true);
        } else {
          AppPref.setIsInitPeruse(false);
        }
        notifyListeners();
      }
    } catch (e) {
      log("Error fetching user profile: $e");
    }
  }

  Future<void> setInitialBalance(double balance) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({'initialBalance': balance}, SetOptions(merge: true));
      initialBalance = balance;
      AppPref.setInitMoney(balance.toString());
      AppPref.setIsInitPeruse(true);
      notifyListeners();
    } catch (e) {
      log("Error setting initial balance: $e");
    }
  }

  Future<void> clearLocalDatabase() async {
    await db.clearAllData();
    initialBalance = null;
    userData = null;
    notifyListeners();
  }

  Future<bool> updateUserProfile(String name, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        'name': name,
        'phone': phone,
        'email': user.email,
      }, SetOptions(merge: true));
      await fetchUserProfile();
      return true;
    } catch (e) {
      log("Error updating user profile: $e");
      return false;
    }
  }

  Future<void> loadUnsyncedData() async {
    log("loadUnsyncedData Called");
    final userId = AppPref.getUid();
    final unsynced = await transactionDao.getUnsyncedTransactions(userId);
    unsyncedTransactions = unsynced.map((row) => ExpenseModel.fromDrift(row)).toList();
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// ============================== FIREBASE DATA ============================== ///
  Future<bool> addExpenseToServer(ExpenseModel expense) async {
    if (!await InternetConnection.isConnected()) {
      log("No Internet Connection");
      return false;
    }
    log("addExpenseToServer Called with expense: ${expense.toJson()}");
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log("User is not logged in! Cannot save to server.");
      return false;
    }

    final uid = user.uid;
    final reference = FirebaseFirestore.instance.collection("users").doc(uid);

    final isIncome = expense.type == "income";

    final docRef = reference.collection(isIncome ? "incomes" : "expenses").doc(expense.id);

    try {
      await docRef.set(expense.toJson());
      log("Expense saved to Firestore with ID: ${docRef.id}");
      return true;
    } catch (e) {
      log("Error saving to server: $e");
      return false;
    }
  }

  Future<String> syncAllData() async {
    log("syncAllData Called");
    if (!await InternetConnection.isConnected()) return "No Internet Connection";
    if (FirebaseAuth.instance.currentUser == null) return "User Not Logged In";

    toServer = true;
    notifyListeners();

    await fetchUserProfile();

    // Sync all existing transactions to Firebase (pending data only?)
    bool allSuccess = true;

    final userId = AppPref.getUid();
    final unsynced = await transactionDao.getUnsyncedTransactions(userId);

    for (var row in unsynced) {
      final model = ExpenseModel.fromDrift(row);
      bool success = await addExpenseToServer(model);
      if (success) {
        await transactionDao.markAsSynced(model.id!);
      } else {
        allSuccess = false;
      }
    }

    await loadUnsyncedData(); // Refresh list after sync

    if (allSuccess) {
      await fetchFromServer(); // Fetch updates from server
      await loadUnsyncedData(); // Refresh list final time

      toServer = false;
      notifyListeners();
      return "Sync Completed (Uploaded & Downloaded).";
    } else {
      await fetchFromServer(); // Try to fetch even if upload had some failures
      await loadUnsyncedData();

      toServer = false;
      notifyListeners();
      return "Sync Partial (Some uploads failed).";
    }
  }

  Future<String> fetchFromServer() async {
    log("fetchFromServer Called");
    if (!await InternetConnection.isConnected()) return "No Internet Connection";
    setLoading(true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log("User is not logged in! Cannot fetch from server.");
      setLoading(false);
      return "User Not Logged In";
    }

    final uid = user.uid;
    final reference = FirebaseFirestore.instance.collection("users").doc(uid);

    try {
      final expenseSnapshot = await reference.collection("expenses").get();
      for (var doc in expenseSnapshot.docs) {
        final data = doc.data();
        final model = ExpenseModel.fromJson(data);
        await _saveFetchedTransaction(model, uid);
      }

      final incomeSnapshot = await reference.collection("incomes").get();
      for (var doc in incomeSnapshot.docs) {
        final data = doc.data();
        final model = ExpenseModel.fromJson(data);
        await _saveFetchedTransaction(model, uid);
      }

      log("Data fetched from server and saved to Drift.");
    } catch (e) {
      log("Error fetching data: $e");
    } finally {
      setLoading(false);
    }
    return "Data fetched from server and saved to Drift.";
  }

  Future<void> _saveFetchedTransaction(ExpenseModel model, String userId) async {
    int? catId;
    if (model.category != null) {
      var c = await categoriesDao.getCategoryByName(model.category!, userId);
      if (c == null) {
        await categoriesDao.insertCategory(
          CategoriesCompanion(name: drift.Value(model.category!), type: drift.Value(model.type ?? "expense"), userId: drift.Value(userId)),
        );
        c = await categoriesDao.getCategoryByName(model.category!, userId);
      }
      catId = c?.id;
    }

    int? pmId;
    if (model.paymentMethod != null) {
      var p = await paymentMethodsDao.getPaymentMethodByName(model.paymentMethod!, userId);
      if (p == null) {
        await paymentMethodsDao.insertPaymentMethod(PaymentMethodsCompanion(name: drift.Value(model.paymentMethod!), userId: drift.Value(userId)));
        p = await paymentMethodsDao.getPaymentMethodByName(model.paymentMethod!, userId);
      }
      pmId = p?.id;
    }

    final companion = model
        .toCompanion(userId, catId: catId, pmId: pmId)
        .copyWith(
          isSync: const drift.Value(1), // Mark as synced since it came from server
        );

    try {
      await transactionDao.insertTransaction(companion);
    } catch (e) {
      // Likely duplicate, update instead?
      if (model.id != null) {
        await transactionDao.updateTransactionByExternalId(model.id!, companion);
      }
    }
  }
}
