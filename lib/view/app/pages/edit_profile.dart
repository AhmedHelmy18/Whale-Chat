import 'package:flutter/material.dart';
import 'package:whale_chat/controller/profile/edit_profile_controller.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/widgets/edit_container.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late EditProfileController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = EditProfileController();
    loadData();
  }

  Future<void> loadData() async {
    await controller.getData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateField(String field) async {
    bool success = await controller.updateField(field: field);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "$field updated!" : "Failed to update $field"),
      ),
    );
    if (success) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.surface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: colorScheme.surface,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'Edit your name or bio',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                EditContainer(
                  text: 'Your Name:',
                  hint: 'Enter new name',
                  controller: controller.nameController,
                  updateProfilePage: () => updateField('name'),
                ),
                const SizedBox(height: 20),
                EditContainer(
                  text: 'Your Bio:',
                  hint: 'Enter new bio',
                  controller: controller.bioController,
                  updateProfilePage: () => updateField('bio'),
                ),
              ],
            ),
    );
  }
}
