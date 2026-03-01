import 'package:expence_tracker/auth/controller/auth_provider.dart';
import 'package:expence_tracker/auth/view/screens/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/custom_toast.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || password.length < 6) {
      CustomeToast.showError(context, "Password must be at least 6 characters");
      return;
    }
    if (password != confirmPassword) {
      CustomeToast.showError(context, "Passwords do not match");
      return;
    }

    String? error = await authProvider.updatePassword(password);

    if (!mounted) return;

    if (error == null) {
      CustomeToast.showSuccess(context, "Password Reset Successful! Please Login.");
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    } else {
      CustomeToast.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Top Gradient Background
              Container(
                height: size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.lock_reset, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Reset Password",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 5),
                    Text("Set your new password", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16)),
                    const SizedBox(height: 50),
                  ],
                ),
              ),

              // Bottom White Container
              Positioned(
                top: size.height * 0.35,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: passwordController,
                          hintText: "New Password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: confirmPasswordController,
                          hintText: "Confirm Password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 30),
                        AppButton(label: "UPDATE PASSWORD", onPressed: _updatePassword, isLoading: authProvider.isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
