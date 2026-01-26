import 'package:flutter/material.dart';
import 'package:whale_chat/controller/profile/edit_profile_controller.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/profile/edit_profile_widget.dart';
import 'package:whale_chat/view/common/image_options/model_sheet_options.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late EditProfileController controller;
  bool isLoading = true;
  late Future<String?> profileImageFuture;

  @override
  void initState() {
    super.initState();
    controller = EditProfileController();
    profileImageFuture = controller.getProfileImageUrl();
    loadData();
  }

  Future<void> loadData() async {
    await controller.getData();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> updateField(String field) async {
    final success = await controller.updateField(field: field);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "$field updated!" : "Failed to update $field"),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: colorScheme.surface),
          onPressed: () => Navigator.pop(context),
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
      ),
      body: isLoading ? Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      )
          : Container(
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
              FutureBuilder<String?>(
                future: profileImageFuture,
                builder: (context, snapshot) {
                  return GestureDetector(
                    onTap: () {
                      showImageSourcePicker(
                        context: context,
                        onPick: (source) async {
                          await controller.uploadProfileImage(source);
                          if (!mounted) return;
                          setState(() {
                            profileImageFuture = controller.getProfileImageUrl();
                          });
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
                                color: colorScheme.onPrimary.withValues(alpha: 0.2),
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
                            backgroundImage: snapshot.data == null
                                ? const AssetImage('assets/images/download.jpeg')
                                : NetworkImage(snapshot.data!) as ImageProvider,
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
                                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
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
                      controller: controller.nameController,
                      updateProfileScreen: () => updateField('name'),
                    ),
                    const SizedBox(height: 25),
                    EditContainer(
                      text: 'Your Bio:',
                      hint: 'Enter new bio',
                      controller: controller.bioController,
                      updateProfileScreen: () => updateField('bio'),
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