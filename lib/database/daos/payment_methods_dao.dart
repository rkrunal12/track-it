import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/payment_methods.dart';

part 'payment_methods_dao.g.dart';

@DriftAccessor(tables: [PaymentMethods])
class PaymentMethodsDao extends DatabaseAccessor<AppDatabase> with _$PaymentMethodsDaoMixin {
  PaymentMethodsDao(super.db);

  Future<List<PaymentMethod>> getAllPaymentMethods(String userId) => (select(paymentMethods)..where((t) => t.userId.equals(userId))).get();
  Future<int> insertPaymentMethod(PaymentMethodsCompanion entry) => into(paymentMethods).insert(entry);
  Future<int> deletePaymentMethod(String name, String userId) =>
      (delete(paymentMethods)..where((t) => t.name.equals(name) & t.userId.equals(userId))).go();
  Future<int> updatePaymentMethod(String oldName, String userId, PaymentMethodsCompanion entry) =>
      (update(paymentMethods)..where((t) => t.name.equals(oldName) & t.userId.equals(userId))).write(entry);
  Future<PaymentMethod?> getPaymentMethodByName(String name, String userId) =>
      (select(paymentMethods)..where((t) => t.name.equals(name) & t.userId.equals(userId))).getSingleOrNull();
}
