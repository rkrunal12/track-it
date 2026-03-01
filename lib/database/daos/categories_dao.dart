import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/categories.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<List<Category>> getAllCategories(String userId) => (select(categories)..where((t) => t.userId.equals(userId))).get();

  Future<List<Category>> getCategoriesByType(String type, String userId) =>
      (select(categories)..where((t) => t.type.equals(type) & t.userId.equals(userId))).get();

  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);

  Future<int> deleteCategory(String name, String type, String userId) =>
      (delete(categories)..where((t) => t.name.equals(name) & t.type.equals(type) & t.userId.equals(userId))).go();

  Future<int> updateCategory(String oldName, String type, String userId, CategoriesCompanion entry) =>
      (update(categories)..where((t) => t.name.equals(oldName) & t.type.equals(type) & t.userId.equals(userId))).write(entry);

  Future<Category?> getCategoryByName(String name, String userId) =>
      (select(categories)..where((t) => t.name.equals(name) & t.userId.equals(userId))).getSingleOrNull();
}
