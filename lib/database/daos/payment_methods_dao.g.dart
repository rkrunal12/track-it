// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_methods_dao.dart';

// ignore_for_file: type=lint
mixin _$PaymentMethodsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PaymentMethodsTable get paymentMethods => attachedDatabase.paymentMethods;
  PaymentMethodsDaoManager get managers => PaymentMethodsDaoManager(this);
}

class PaymentMethodsDaoManager {
  final _$PaymentMethodsDaoMixin _db;
  PaymentMethodsDaoManager(this._db);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(
        _db.attachedDatabase,
        _db.paymentMethods,
      );
}
