import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/profile/edit_profile_widget.dart';
import 'package:whale_chat/view/common/image_options/model_sheet_options.dart';
import 'package:whale_chat/view_model/profile_view_model.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String? currentBio;

  const EditProfileScreen(
      {super.key, required this.currentName, this.currentBio});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileViewModel viewModel = ProfileViewModel();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String? _newImageUrl;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    nameController.text = widget.currentName;
    bioController.text = widget.currentBio ?? '';

    // Load fresh data just in case
    viewModel.loadProfile(_currentUserId).then((_) {
      if (mounted && viewModel.user != null) {
        setState(() {
          nameController.text = viewModel.user!.name;
          bioController.text = viewModel.user!.about;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    final success = await viewModel.updateProfile(
      name: nameController.text.trim(),
      about: bioController.text.trim(),
      imageUrl: _newImageUrl,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(success ? "Profile updated!" : "Failed to update profile"),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: colorScheme.surface),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: colorScheme.surface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return ElevatedButton.icon(
                  onPressed: viewModel.isSaving ? null : updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.primary,
                    elevation: 2,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  icon: viewModel.isSaving
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(2),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(Icons.check_rounded,
                          size: 20, color: colorScheme.primary),
                  label: Text(
                    viewModel.isSaving ? "Saving..." : "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.surface,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  final displayImage = _newImageUrl ?? viewModel.user?.image ?? "";

                  return GestureDetector(
                    onTap: () {
                      showImageSourcePicker(
                        context: context,
                        onPick: (source) async {
                          final picker = ImagePicker();
                          final XFile? picked = await picker.pickImage(source: source, imageQuality: 80);
                          if (picked != null) {
                             final url = await viewModel.uploadImage(_currentUserId, File(picked.path));
                             if (mounted && url != null) {
                               setState(() {
                                 _newImageUrl = url;
                               });
                             }
                          }
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.onPrimary
                                    .withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 85,
                            backgroundImage: displayImage.isEmpty
                                ? const AssetImage(
                                    'assets/images/download.jpeg')
                                : NetworkImage(displayImage)
                                    as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.onPrimary
                                      .withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: colorScheme.surface,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              Text(
                'Tap to change photo',
                style: TextStyle(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    EditContainer(
                      text: 'Your Name:',
                      hint: 'Enter new name',
                      controller: nameController,
                    ),
                    const SizedBox(height: 25),
                    EditContainer(
                      text: 'Your Bio:',
                      hint: 'Enter new bio',
                      controller: bioController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
