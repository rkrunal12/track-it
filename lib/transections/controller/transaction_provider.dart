import 'dart:developer';
import 'package:flutter/material.dart';

import '../../database/daos/transactions_dao.dart';
import '../../database/daos/categories_dao.dart';
import '../../database/daos/payment_methods_dao.dart';
import '../../transections/model/expense_model.dart';
import '../../shared/data/shared_pref_data.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionDao transactionDao;
  final CategoriesDao categoriesDao;
  final PaymentMethodsDao paymentMethodsDao;

  TransactionProvider(this.transactionDao, this.categoriesDao, this.paymentMethodsDao);

  // =============== INDEX =================
  int index = 0;
  void setIndex(int value) {
    log("setIndex Called with value: $value");
    if (value != 1) {
      setFilterIndex(null);
    }
    index = value;
    notifyListeners();
  }

  int typeOfTransaction = 0;
  void setTypeOfTransaction(int value) {
    log("setTypeOfTransaction Called with value: $value");
    typeOfTransaction = value;
    notifyListeners();
  }

  // =============== INITIALIZE ===============
  List<ExpenseModel> _allTransactions = [];

  Future<void> initTransaction() async {
    log("initTransaction Called (Refreshing Data from Drift)");
    final userId = AppPref.getUid();
    if (userId.isEmpty) {
      _allTransactions = [];
      notifyListeners();
      return;
    }

    // Use DAO
    final result = await transactionDao.getAllTransactions(userId);

    _allTransactions = result.map((row) => ExpenseModel.fromDrift(row)).toList();

    notifyListeners();
  }

  // =============== SELECTED PAYMENT AND CATEGORY ===============
  String? selectedCategory;
  String? selectedPaymentMethod;
  String title = "";
  String amount = "";
  String note = "";

  // New Filters
  DateTimeRange? dateRange;
  RangeValues? amountRange;

  void setDateRange(DateTimeRange? range) {
    dateRange = range;
    notifyListeners();
  }

  void setAmountRange(RangeValues? range) {
    amountRange = range;
    notifyListeners();
  }

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setAmount(String value) {
    amount = value;
    notifyListeners();
  }

  void setNote(String value) {
    note = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    log("setCategory Called with value: $value");
    selectedCategory = value;
    notifyListeners();
  }

  void setPaymentMethod(String? value) {
    log("setPaymentMethod Called with value: $value");
    selectedPaymentMethod = value;
    notifyListeners();
  }

  /// ============================== TRANSECTION DATA ============================== ///
  /// ============================== TRANSECTION DATA ============================== ///
  List<ExpenseModel> get allTransactions => _allTransactions;
  List<ExpenseModel> get expenses => allTransactions.where((t) => t.type == "expense").toList();
  List<ExpenseModel> get incomes => allTransactions.where((t) => t.type == "income").toList();

  // =============== ADD TRANSECTION =================
  // =============== ADD TRANSECTION =================
  Future<void> addTransaction(ExpenseModel model) async {
    log("addTransaction Called with model: ${model.toJson()}");

    final userId = AppPref.getUid();

    int? catId;
    if (selectedCategory != null) {
      final c = await categoriesDao.getCategoryByName(selectedCategory!, userId);
      catId = c?.id;
    }

    int? pmId;
    if (selectedPaymentMethod != null) {
      final p = await paymentMethodsDao.getPaymentMethodByName(selectedPaymentMethod!, userId);
      pmId = p?.id;
    }

    final newId = "tr-${DateTime.now().millisecondsSinceEpoch}";
    model.id = newId; // Update model ID
    final newItemCompanion = model.toCompanion(userId, catId: catId, pmId: pmId);

    await transactionDao.insertTransaction(newItemCompanion);

    // HiveData.addDataToHive(newItem); // Removed Hive
    // HiveData.pendingData(newItem); // TODO: Adapt for Sync

    selectedCategory = null;
    selectedPaymentMethod = null;
    title = "";
    amount = "";
    note = "";
    await initTransaction();
  }

  // =============== UPDATE TRANSECTION =================
  // =============== UPDATE TRANSECTION =================
  Future<void> updateTransaction(ExpenseModel model) async {
    log("updateTransaction Called with model: ${model.toJson()}");

    final userId = AppPref.getUid();

    int? catId;
    if (model.category != null) {
      final c = await categoriesDao.getCategoryByName(model.category!, userId);
      catId = c?.id;
    }

    int? pmId;
    if (model.paymentMethod != null) {
      final p = await paymentMethodsDao.getPaymentMethodByName(model.paymentMethod!, userId);
      pmId = p?.id;
    }

    final updateCompanion = model.toCompanion(userId, catId: catId, pmId: pmId);
    await transactionDao.updateTransactionByExternalId(model.id!, updateCompanion);

    // HiveData.updateData(model);
    // HiveData.updatePendingData(model);
    selectedCategory = null;
    selectedPaymentMethod = null;
    title = "";
    amount = "";
    note = "";
    await initTransaction();
  }

  Future<void> removeTransaction(String id) async {
    log("removeTransaction Called with id: $id");
    await transactionDao.deleteTransactionByExternalId(id);
    // HiveData.removeDataFromHive(id);
    // HiveData.removePendingData(id);
    await initTransaction();
  }

  // =============== FORM VALIDATION =================
  bool isFormValid() {
    log("isFormValid Called");
    return title.isNotEmpty && amount.isNotEmpty && note.isNotEmpty && selectedCategory != null && selectedPaymentMethod != null;
  }

  // =============== SEARCH QUERY =================
  String searchQuery = "";
  void setSearchQuery(String value) {
    log("setSearchQuery Called with value: $value");
    searchQuery = value;
    notifyListeners();
  }

  // =============== FILTERING & GROUPING LOGIC ===============

  List<ExpenseModel> get _processedTransactions {
    return _allTransactions.where((t) {
      // 1. Search filter
      final matchesSearch = searchQuery.isEmpty || (t.title?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

      // 2. Date Range filter
      bool matchesDate = true;
      if (dateRange != null) {
        if (t.date == null) {
          matchesDate = false;
        } else {
          // Compare only dates (ignoring time)
          final date = DateTime(t.date!.year, t.date!.month, t.date!.day);
          final start = DateTime(dateRange!.start.year, dateRange!.start.month, dateRange!.start.day);
          final end = DateTime(dateRange!.end.year, dateRange!.end.month, dateRange!.end.day);
          matchesDate = date.isAtSameMomentAs(start) || date.isAtSameMomentAs(end) || (date.isAfter(start) && date.isBefore(end));
        }
      }

      // 3. Amount Range filter
      bool matchesAmount = true;
      if (amountRange != null) {
        final val = t.amount ?? 0;
        matchesAmount = val >= amountRange!.start && val <= amountRange!.end;
      }

      // 4. Category filter
      final matchesCategory = cate.isEmpty || cate.contains(t.category);

      // 5. Payment Method filter
      final matchesMethod = method.isEmpty || method.contains(t.paymentMethod);

      return matchesSearch && matchesDate && matchesAmount && matchesCategory && matchesMethod;
    }).toList();
  }

  /// Groups transactions by Category for the UI.
  /// Only categories with at least one transaction after filtering will be keys in this map.
  Map<String, List<ExpenseModel>> getGroupedTransactions({bool? isIncome}) {
    final filtered = _processedTransactions.where((t) {
      if (isIncome == null) return true;
      return isIncome ? t.type == "income" : t.type == "expense";
    }).toList();

    // Sort by date primary
    filtered.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));

    final Map<String, List<ExpenseModel>> groups = {};
    for (var t in filtered) {
      final key = t.category ?? "General";
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(t);
    }
    return groups;
  }

  double getMinAmount() => _allTransactions.isEmpty ? 0 : _allTransactions.map((e) => e.amount ?? 0).reduce((a, b) => a < b ? a : b);
  double getMaxAmount() => _allTransactions.isEmpty ? 10000 : _allTransactions.map((e) => e.amount ?? 0).reduce((a, b) => a > b ? a : b);

  int? filterIndex;

  void setFilterIndex(int? value) {
    log("setFilterIndex Called with value: $value");
    filterIndex = value;
    if (value == null) {
      sort = null;
      method = [];
      cate = [];
    }
    notifyListeners();
  }

  List<ExpenseModel> get sorted => List.from(allTransactions)..sort((a, b) => b.amount!.compareTo(a.amount ?? 0));

  bool? sort;

  void setSort(bool? isSort) {
    log("setSort Called with isSort: $isSort");
    if (filterIndex == 1) {
      sort = isSort;
      notifyListeners();
    }
  }

  List<String> cate = [];
  List<ExpenseModel> get cateFilter {
    if (cate.isEmpty) return allTransactions;
    return allTransactions.where((t) => cate.contains(t.category)).toList();
  }

  void addToCate(String value) {
    log("addToCate Called with value: $value");
    if (cate.contains(value)) {
      cate.remove(value);
    } else {
      cate.add(value);
    }
    log("$cate");
    notifyListeners();
  }

  List<String> method = [];
  List<ExpenseModel> get payFilter {
    if (method.isEmpty) return allTransactions;
    return allTransactions.where((t) => method.contains(t.paymentMethod)).toList();
  }

  void addToMethod(String value) {
    log("addToMethod Called with value: $value");
    if (method.contains(value)) {
      method.remove(value);
    } else {
      method.add(value);
    }
    log("$method");
    notifyListeners();
  }
}
