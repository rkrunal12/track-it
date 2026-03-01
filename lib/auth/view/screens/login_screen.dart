import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/auth_provider.dart';
import '../../../shared/data/firebase_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../../transections/view/screens/home_screen.dart';
import '../../../shared/data/shared_pref_data.dart';
import '../../../shared/widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  final bool isReplacement;
  const LoginScreen({super.key, this.isReplacement = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      CustomeToast.showError(context, "Please enter a valid email address");
      return;
    }
    if (password.isEmpty || password.length < 6) {
      CustomeToast.showError(context, "Please enter your password");
      return;
    }

    String? error = await authProvider.signIn(email, password);

    if (!mounted) return;

    if (error == null) {
      CustomeToast.showSuccess(context, "Login Successful!");
      AppPref.setIsLogin(true);
      if (authProvider.currentUser != null) {
        AppPref.setUid(authProvider.currentUser!.uid);
      }

      if (mounted) {
        final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
        await firebaseProvider.fetchFromServer();
        await firebaseProvider.fetchUserProfile();
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
        }
      }
    } else {
      CustomeToast.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              height: size.height * 0.4,
              width: size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF6366F1).withValues(alpha: 0.2), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              height: size.height * 0.4,
              width: size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFFA855F7).withValues(alpha: 0.1), Colors.transparent]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 45,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Sign in to access your financial insights",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),

                  _buildLabel("Email Address"),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: emailController,
                    hintText: "Enter your email",
                    prefixIcon: true,
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  _buildLabel("Password"),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Enter your password",
                    prefixIcon: true,
                    isPassword: true,
                    icon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.done,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  AppButton(label: "Sign In", onPressed: _login, isLoading: authProvider.isLoading),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Or sign in with",
                      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                        },
                        child: Text(
                          "Create one",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
