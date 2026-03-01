import 'package:drift/drift.dart';

// Table for Payment Methods
class PaymentMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get userId => text().nullable()(); // Add userId
}
