import 'package:expence_tracker/database/database.dart';
import 'package:expence_tracker/database/daos/transactions_dao.dart';
import 'package:expence_tracker/database/daos/categories_dao.dart';
import 'package:expence_tracker/database/daos/payment_methods_dao.dart';
import 'package:expence_tracker/settings/controller/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../controller/theme_provider.dart';
import 'package:expence_tracker/auth/controller/auth_provider.dart';
import 'package:expence_tracker/shared/data/firebase_provider.dart';
import 'package:expence_tracker/transections/controller/transaction_provider.dart';

class AllController {
  static List<SingleChildWidget> providers = [
    Provider<AppDatabase>(create: (_) => AppDatabase()),

    Provider<TransactionDao>(create: (context) => TransactionDao(context.read<AppDatabase>())),
    Provider<CategoriesDao>(create: (context) => CategoriesDao(context.read<AppDatabase>())),
    Provider<PaymentMethodsDao>(create: (context) => PaymentMethodsDao(context.read<AppDatabase>())),

    ChangeNotifierProvider(create: (context) => SettingsProvider(context.read<CategoriesDao>(), context.read<PaymentMethodsDao>())),

    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),

    ChangeNotifierProvider(
      create: (context) => TransactionProvider(context.read<TransactionDao>(), context.read<CategoriesDao>(), context.read<PaymentMethodsDao>()),
    ),

    ChangeNotifierProvider(
      create: (context) => FirebaseProvider(
        context.read<TransactionDao>(),
        context.read<CategoriesDao>(),
        context.read<PaymentMethodsDao>(),
        context.read<AppDatabase>(),
      ),
    ),
  ];
}
