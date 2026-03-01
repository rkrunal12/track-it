import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:provider/provider.dart';
import 'shared/controller/all_controller.dart';
import 'shared/widgets/splash_screen.dart';

import 'firebase_options.dart';
import 'shared/controller/theme_provider.dart';
import 'shared/theme/app_theme.dart';
import 'shared/data/shared_pref_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AppPref.init();

  runApp(DevicePreview(enabled: kDebugMode, builder: (context) => const MyApp()));
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AllController.providers,
      child: Selector<ThemeProvider, ThemeMode>(
        selector: (context, themeProvider) => themeProvider.themeMode,
        shouldRebuild: (prev, next) => prev != next,
        builder: (context, themeMode, child) {
          return ToastificationWrapper(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
