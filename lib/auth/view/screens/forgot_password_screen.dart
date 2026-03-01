import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_toast.dart';
import '../../controller/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      CustomeToast.showError(context, "Please enter a valid email address");
      return;
    }

    String? error = await authProvider.resetPassword(email);

    if (!mounted) return;

    if (error == null) {
      CustomeToast.showSuccess(context, "Password reset link sent to your email.");
      Navigator.pop(context);
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
          // Background Glow
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              height: size.height * 0.4,
              width: size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF6366F1).withValues(alpha: 0.1), Colors.transparent]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
                    style: IconButton.styleFrom(backgroundColor: Theme.of(context).cardTheme.color, padding: const EdgeInsets.all(12)),
                  ),
                  const SizedBox(height: 60),
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
                        Icons.lock_reset_rounded,
                        size: 45,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text("Reset Password", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Enter your email address and we'll send you instructions to reset your password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 50),

                  _buildLabel("Email Address"),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: emailController,
                    hintText: "Enter your email",
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 40),

                  AppButton(label: "Send Link", onPressed: _resetPassword, isLoading: authProvider.isLoading),
                  const SizedBox(height: 40),
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
