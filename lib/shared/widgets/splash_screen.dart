import 'package:flutter/material.dart';
import 'package:expence_tracker/auth/view/screens/login_screen.dart';
import '../../transections/view/screens/home_screen.dart';
import '../data/shared_pref_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (AppPref.getIsLogin()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glow
          Center(
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Theme.of(context).primaryColor.withValues(alpha: 0.1), Colors.transparent]),
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.7)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 60,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text("TrackIt", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text(
                          "Your Personal Wealth Companion",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
