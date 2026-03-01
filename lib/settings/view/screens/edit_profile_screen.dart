import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/data/firebase_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_toast.dart';
import '../../../shared/widgets/app_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FirebaseProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.userData?['name'] ?? "");
    _phoneController = TextEditingController(text: provider.userData?['phone'] ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FirebaseProvider>(context, listen: false);
      bool success = await provider.updateUserProfile(_nameController.text.trim(), _phoneController.text.trim());

      if (!mounted) return;

      if (success) {
        CustomeToast.showSuccess(context, "Profile updated successfully!");
        Navigator.pop(context);
      } else {
        CustomeToast.showError(context, "Failed to update profile.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 50),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _fieldLabel("Full Name"),
              CustomTextField(
                controller: _nameController,
                hintText: "Enter your name",
                icon: Icons.person_outline_rounded,
                validator: (val) => (val == null || val.isEmpty) ? "Name is required" : null,
              ),

              const SizedBox(height: 24),

              _fieldLabel("Phone Number"),
              CustomTextField(
                controller: _phoneController,
                hintText: "Enter phone number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => (val == null || val.isEmpty) ? "Phone number is required" : null,
              ),

              const SizedBox(height: 60),

              AppButton(label: "Save Changes", onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
