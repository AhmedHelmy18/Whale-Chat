import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? data;

  Future<void> getData() async {
    try {
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userData.exists) {
        data = userData.data() as Map<String, dynamic>?;
        nameController.text = data?['name'] ?? "";
        bioController.text =
            data?.containsKey('bio') == true ? data!['bio'] : "";
      }
    } catch (e) {
      log("Error getting user data: $e");
    }
  }

  Future<bool> updateField({required String field}) async {
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
      data?[field] = updateData[field];
      return true;
    } catch (e) {
      log("Error updating $field: $e");
      return false;
    }
  }
}
