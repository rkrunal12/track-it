import 'package:expence_tracker/auth/controller/auth_provider.dart';
import 'package:expence_tracker/auth/view/screens/login_screen.dart';
import 'package:expence_tracker/settings/view/screens/categories_screen.dart';
import 'package:expence_tracker/settings/view/screens/sync_screen.dart';
import 'package:expence_tracker/shared/controller/theme_provider.dart';
import 'package:expence_tracker/shared/data/firebase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Settings"), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const SizedBox(height: 25),

            // Profile Section
            const ProfileSection(),

            const SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                "PREFERENCES",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Selector<ThemeProvider, ThemeMode>(
              selector: (context, themeProvider) => themeProvider.themeMode,
              shouldRebuild: (prev, next) => prev != next,
              builder: (context, themeMode, child) {
                return SettingsToggle(
                  icon: Icons.dark_mode_rounded,
                  title: "Dark Mode",
                  value: themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    final themeProvider = context.read<ThemeProvider>();
                    themeProvider.toggleTheme(val);
                  },
                );
              },
            ),
            SettingsTile(
              icon: Icons.category_rounded,
              title: "Categories",
              subtitle: "Manage labels",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen())),
            ),
            SettingsTile(
              icon: Icons.sync_rounded,
              title: "Sync Data",
              subtitle: "Cloud backup",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SyncScreen())),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await Provider.of<FirebaseProvider>(context, listen: false).clearLocalDatabase();
                  if (context.mounted) {
                    Provider.of<AuthProvider>(context, listen: false).signOut();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                  }
                },
                child: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
