import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/data/firebase_provider.dart';
import '../screens/edit_profile_screen.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<FirebaseProvider, (String, Map<String, dynamic>)>(
      selector: (context, provider) => (provider.userData?['name'] ?? "User", provider.userData ?? {}),
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, data, child) {
        final (name, userData) = data;
        final email = userData['email'] ?? "email@example.com";

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor, size: 20),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
