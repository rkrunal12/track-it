import 'package:expence_tracker/auth/view/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_toast.dart';
import '../../controller/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      CustomeToast.showError(context, "Please enter your name");
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      CustomeToast.showError(context, "Please enter a valid phone number");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      CustomeToast.showError(context, "Please enter a valid email address");
      return;
    }
    if (password.isEmpty || password.length < 6) {
      CustomeToast.showError(context, "Password must be at least 6 characters");
      return;
    }
    if (password != confirmPassword) {
      CustomeToast.showError(context, "Passwords do not match");
      return;
    }

    String? error = await authProvider.signUp(email, password, name, phone);

    if (!mounted) return;

    if (error == null) {
      CustomeToast.showSuccess(context, "Registration Successful!");
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              height: size.height * 0.4,
              width: size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFFA855F7).withValues(alpha: 0.15), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              height: size.height * 0.4,
              width: size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF6366F1).withValues(alpha: 0.15), Colors.transparent]),
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
                  const SizedBox(height: 20),
                  const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text(
                    "Join over 10,000+ users managing their wealth",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  _buildLabel("Full Name"),
                  const SizedBox(height: 10),
                  CustomTextField(controller: nameController, hintText: "Enter your name", icon: Icons.person_outline_rounded),
                  const SizedBox(height: 20),

                  _buildLabel("Phone Number"),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: phoneController,
                    hintText: "Enter phone number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Email Address"),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: emailController,
                    hintText: "Enter your email",
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Password"),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Create a strong password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Confirm Password"),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: confirmPasswordController,
                    hintText: "Repeat your password",
                    icon: Icons.lock_clock_outlined,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 40),

                  AppButton(label: "Register Now", onPressed: _signup, isLoading: authProvider.isLoading),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already part of the tribe? ", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        },
                        child: Text(
                          "Log in",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
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
