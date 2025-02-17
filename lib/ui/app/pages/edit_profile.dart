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

  @override
  initState() {
    super.initState();
  }

  Future<void> getData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userData.exists) {
        setState(() {
          nameController.text = userData['name'] ?? '';
          bioController.text = userData['bio'] ?? '';
        });
      }
    } catch (e) {
      log("Error getting user data: $e");
    }
  }

  Future<void> updateProfile() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'name': nameController.text, 'bio': bioController.text});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile updated successfully!"),
        ),
      );
    } catch (e) {
      log("Error updating user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile"),
        ),
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
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Center(
              child: Text(
                'Edit your name and bio',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          EditContainer(
            text: 'Your Name :',
            hint: 'Enter new name.',
            controller: nameController,
            updateProfile: updateProfile,
          ),
          SizedBox(
            height: 20,
          ),
          EditContainer(
            text: 'Your Bio :',
            hint: 'Enter new bio.',
            controller: bioController,
            updateProfile: updateProfile,
          ),
        ],
      ),
    );
  }
}
