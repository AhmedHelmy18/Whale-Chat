import 'dart:developer';
import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/widgets/edit_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  late Map<String, dynamic>? data;

  @override
  initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      data = userData.data() as Map<String, dynamic>?;

      if (userData.exists) {
        setState(() {
          nameController.text = userData['name'] ?? "";
          bioController.text =
              data?.containsKey("bio") == true ? data!["bio"] : "";
        });
      }
    } catch (e) {
      log("Error getting user data: $e");
    }
  }

  Future<void> updateProfile({required String field}) async {
    try {
      Map<String, dynamic> updateData = {};
      if (field == 'name') {
        updateData['name'] = nameController.text;
      } else if (field == 'bio') {
        updateData['bio'] = bioController.text;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$field updated successfully!")),
      );
    } catch (e) {
      log("Error updating $field: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update $field")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.surface,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: colorScheme.surface,
          ),
        ),
      ),
      body: Column(
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
            controller: nameController,
            updateProfile: () => updateProfile(field: 'name'),
          ),
          const SizedBox(height: 20),
          EditContainer(
            text: 'Your Bio:',
            hint: 'Enter new bio',
            controller: bioController,
            updateProfile: () => updateProfile(field: 'bio'),
          ),
        ],
      ),
    );
  }
}
