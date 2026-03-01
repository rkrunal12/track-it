import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';
import '../../database/daos/transactions_dao.dart';

class ExpenseModel {
  String? id;
  String? title;
  double? amount;
  String? category;
  DateTime? date;
  String? note;
  String? paymentMethod;
  String? type; // "income" OR "expense"

  ExpenseModel({this.id, this.title, this.amount, this.category, this.date, this.note, this.paymentMethod, this.type});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date?.toIso8601String(),
      'note': note,
      'paymentMethod': paymentMethod,
      'type': type,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount']?.toDouble(),
      category: json['category'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      note: json['note'],
      paymentMethod: json['paymentMethod'],
      type: json['type'],
    );
  }

  // Convert to Drift Companion
  TransactionsCompanion toCompanion(String userId, {int? catId, int? pmId}) {
    return TransactionsCompanion(
      externalId: drift.Value(id),
      title: drift.Value(title),
      amount: drift.Value(amount),
      categoryId: drift.Value(catId),
      paymentMethodId: drift.Value(pmId),
      date: drift.Value(date),
      note: drift.Value(note),
      type: drift.Value(type),
      userId: drift.Value(userId),
      isSync: const drift.Value(0),
    );
  }

  // Create from Drift Data
  factory ExpenseModel.fromDrift(TransactionWithDetails row) {
    return ExpenseModel(
      id: row.transaction.externalId,
      title: row.transaction.title,
      amount: row.transaction.amount,
      category: row.category?.name,
      date: row.transaction.date,
      note: row.transaction.note,
      paymentMethod: row.paymentMethod?.name,
      type: row.transaction.type,
    );
  }
}
