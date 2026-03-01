import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'daos/transactions_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/payment_methods_dao.dart';
import 'tables/transactions.dart';
import 'tables/categories.dart';
import 'tables/payment_methods.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Transactions, Categories, PaymentMethods], daos: [TransactionDao, CategoriesDao, PaymentMethodsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  // Migration strategy to handle schema updates
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(transactions, transactions.isSync);
        }
        if (from < 3) {
          await m.addColumn(transactions, transactions.userId);
          await m.addColumn(categories, categories.userId);
          await m.addColumn(paymentMethods, paymentMethods.userId);
        }
      },
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Future<void> clearAllData() async {
    await delete(transactions).go();
    await delete(categories).go();
    await delete(paymentMethods).go();
  }
}
