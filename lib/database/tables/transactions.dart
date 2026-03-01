import 'package:drift/drift.dart';
import 'categories.dart';
import 'payment_methods.dart';

// Table for Transactions
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().unique().nullable()(); // To keep the old String ID if needed
  TextColumn get title => text().nullable()();
  RealColumn get amount => real().nullable()();

  // Foreign keys
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get paymentMethodId => integer().nullable().references(PaymentMethods, #id)();

  DateTimeColumn get date => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get type => text().nullable()(); // "income" OR "expense"
  IntColumn get isSync => integer().withDefault(const Constant(0))(); // 0 = false, 1 = true
  TextColumn get userId => text().nullable()(); // Add userId
}
