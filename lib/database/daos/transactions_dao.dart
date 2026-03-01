import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/transactions.dart';
import '../tables/categories.dart';
import '../tables/payment_methods.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions, Categories, PaymentMethods])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // Get all transactions with join
  Future<List<TransactionWithDetails>> getAllTransactions(String userId) async {
    final query = select(transactions).join([
      leftOuterJoin(categories, categories.id.equalsExp(transactions.categoryId)),
      leftOuterJoin(paymentMethods, paymentMethods.id.equalsExp(transactions.paymentMethodId)),
    ])..where(transactions.userId.equals(userId));

    final rows = await query.get();
    return rows.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        category: row.readTableOrNull(categories),
        paymentMethod: row.readTableOrNull(paymentMethods),
      );
    }).toList();
  }

  Future<int> insertTransaction(TransactionsCompanion entry) => into(transactions).insert(entry);

  Future<bool> updateTransaction(TransactionsCompanion entry) => update(transactions).replace(entry);

  Future<int> deleteTransaction(int id) => (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<int> deleteTransactionByExternalId(String id) => (delete(transactions)..where((t) => t.externalId.equals(id))).go();

  Future<void> updateTransactionByExternalId(String id, TransactionsCompanion entry) async {
    await (update(transactions)..where((t) => t.externalId.equals(id))).write(entry);
  }

  Future<List<TransactionWithDetails>> getUnsyncedTransactions(String userId) async {
    final query =
        select(transactions).join([
            leftOuterJoin(categories, categories.id.equalsExp(transactions.categoryId)),
            leftOuterJoin(paymentMethods, paymentMethods.id.equalsExp(transactions.paymentMethodId)),
          ])
          ..where(transactions.userId.equals(userId))
          ..where(transactions.isSync.equals(0));

    final rows = await query.get();
    return rows.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        category: row.readTableOrNull(categories),
        paymentMethod: row.readTableOrNull(paymentMethods),
      );
    }).toList();
  }

  Future<void> markAsSynced(String externalId) async {
    await (update(transactions)..where((t) => t.externalId.equals(externalId))).write(const TransactionsCompanion(isSync: Value(1)));
  }
}

class TransactionWithDetails {
  final Transaction transaction;
  final Category? category;
  final PaymentMethod? paymentMethod;

  TransactionWithDetails({required this.transaction, this.category, this.paymentMethod});
}
