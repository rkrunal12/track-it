import 'package:expence_tracker/shared/data/shared_pref_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/data/firebase_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_toast.dart';
import '../../transections/view/screens/home_screen.dart';
import '../controller/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mode is managed by provider
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(AuthProvider authProvider) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final mode = authProvider.currentMode;

    String? error;

    if (mode == AuthMode.login) {
      if (email.isEmpty || !email.contains('@')) {
        CustomeToast.showError(context, "Please enter a valid email address");
        return;
      }
      if (password.isEmpty) {
        CustomeToast.showError(context, "Please enter your password");
        return;
      }
      error = await authProvider.signIn(email, password);
      if (error == null) {
        _onLoginSuccess(authProvider);
      }
    } else if (mode == AuthMode.signup) {
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
      error = await authProvider.signUp(email, password, name, phone);
      if (error == null) {
        CustomeToast.showSuccess(context, "Account created successfully!");
        authProvider.switchMode(AuthMode.login);
      }
    } else if (mode == AuthMode.forgotPassword) {
      if (email.isEmpty || !email.contains('@')) {
        CustomeToast.showError(context, "Please enter a valid email address");
        return;
      }
      error = await authProvider.resetPassword(email);
      if (error == null) {
        CustomeToast.showSuccess(context, "Password reset link sent to your email!");
        authProvider.switchMode(AuthMode.login);
      }
    } else if (mode == AuthMode.resetPassword) {
      if (password.isEmpty || password.length < 6) {
        CustomeToast.showError(context, "Password must be at least 6 characters");
        return;
      }
      if (password != confirmPassword) {
        CustomeToast.showError(context, "Passwords do not match");
        return;
      }
      error = await authProvider.updatePassword(password);
      if (error == null) {
        CustomeToast.showSuccess(context, "Password updated successfully!");
        authProvider.switchMode(AuthMode.login);
      }
    }

    if (error != null && mounted) {
      CustomeToast.showError(context, error);
    }
  }

  void _onLoginSuccess(AuthProvider authProvider) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(authProvider),

                Column(key: ValueKey(authProvider.currentMode), crossAxisAlignment: CrossAxisAlignment.start, children: _buildFields(authProvider)),

                if (authProvider.currentMode == AuthMode.login)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GestureDetector(
                        onTap: () => authProvider.switchMode(AuthMode.forgotPassword),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 16),

                AppButton(label: getButtonLabel(authProvider), onPressed: () => _handleSubmit(authProvider), isLoading: authProvider.isLoading),

                const SizedBox(height: 24),
                Center(child: _buildFooter(authProvider)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    String title = "";
    String subtitle = "";

    switch (authProvider.currentMode) {
      case AuthMode.login:
        title = "Welcome Back";
        subtitle = "Log in to track your expenses effortlessly.";
        break;
      case AuthMode.signup:
        title = "Create Account";
        subtitle = "Join the elite community today.";
        break;
      case AuthMode.forgotPassword:
        title = "Reset Password";
        subtitle = "Enter your email to recover your account.";
        break;
      case AuthMode.resetPassword:
        title = "New Password";
        subtitle = "Secure your account with a fresh password.";
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (authProvider.currentMode == AuthMode.login)
          Container(
            height: 64,
            width: 64,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.account_balance_wallet_rounded, size: 28, color: Theme.of(context).primaryColor),
          ),
        Center(
          child: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  List<Widget> _buildFields(AuthProvider authProvider) {
    List<Widget> fields = [];
    final mode = authProvider.currentMode;

    void addField(
      String label,
      TextEditingController controller,
      String hint,
      IconData icon, {
      bool isPassword = false,
      TextInputType? keyboardType,
    }) {
      fields.add(_buildLabel(label));
      fields.add(const SizedBox(height: 6));
      fields.add(
        CustomTextField(controller: controller, hintText: hint, prefixIcon: true, icon: icon, isPassword: isPassword, keyboardType: keyboardType),
      );
      fields.add(const SizedBox(height: 16));
    }

    if (mode == AuthMode.login) {
      addField("Email Address", _emailController, "email", Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress);
      addField("Password", _passwordController, "password", Icons.lock_outline_rounded, isPassword: true);
    } else if (mode == AuthMode.signup) {
      addField("Full Name", _nameController, "Full Name", Icons.person_outline_rounded);
      addField("Phone Number", _phoneController, "Phone Number", Icons.phone_outlined, keyboardType: TextInputType.phone);
      addField("Email Address", _emailController, "Email Address", Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress);
      addField("Password", _passwordController, "Password", Icons.lock_outline_rounded, isPassword: true);
      addField("Confirm Password", _confirmPasswordController, "Confirm Password", Icons.lock_clock_outlined, isPassword: true);
    } else if (mode == AuthMode.forgotPassword) {
      addField("Email Address", _emailController, "email", Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress);
    } else if (mode == AuthMode.resetPassword) {
      addField("New Password", _passwordController, "new password", Icons.lock_outline_rounded, isPassword: true);
      addField("Confirm Password", _confirmPasswordController, "repeat password", Icons.lock_clock_outlined, isPassword: true);
    }

    return fields;
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  String getButtonLabel(AuthProvider authProvider) {
    switch (authProvider.currentMode) {
      case AuthMode.login:
        return "Sign In";
      case AuthMode.signup:
        return "Register Now";
      case AuthMode.forgotPassword:
        return "Get Reset Link";
      case AuthMode.resetPassword:
        return "Update Password";
    }
  }

  Widget _buildFooter(AuthProvider authProvider) {
    if (authProvider.currentMode == AuthMode.forgotPassword || authProvider.currentMode == AuthMode.resetPassword) {
      return GestureDetector(
        onTap: () => authProvider.switchMode(AuthMode.login),
        child: Text(
          "Back to Login",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800, fontSize: 14),
        ),
      );
    }

    if (authProvider.currentMode == AuthMode.login) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("New to TrackIt? ", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
          GestureDetector(
            onTap: () => authProvider.switchMode(AuthMode.signup),
            child: Text(
              "Join for free",
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      );
    } else if (authProvider.currentMode == AuthMode.signup) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already a member? ", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
          GestureDetector(
            onTap: () => authProvider.switchMode(AuthMode.login),
            child: Text(
              "Log in now",
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
