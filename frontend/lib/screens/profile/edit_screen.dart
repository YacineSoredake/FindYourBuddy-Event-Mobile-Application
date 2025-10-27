import 'package:flutter/material.dart';
import 'package:frontend/providers/profile_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final user = auth.user;

    if (user != null && nameController.text.isEmpty) {
      nameController.text = user.name;
      bioController.text = user.bio ?? '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);

                      final success = await profileProvider.updateProfile({
                        "name": nameController.text,
                        "bio": bioController.text,
                        "location": locationController.text,
                      });

                      setState(() => isLoading = false);

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated ✅')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update profile ❌'),
                          ),
                        );
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}
