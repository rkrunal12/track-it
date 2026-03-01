import 'package:drift/drift.dart';

// Table for Categories
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get type => text().nullable()(); // "income" or "expense"
  TextColumn get userId => text().nullable()(); // Add userId
}
