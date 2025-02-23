import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = "";
  String? bio = "";
  bool isLoading = true;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  Future<void> getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      var data = userDoc.data() as Map<String, dynamic>?;

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "";
          bio = data?.containsKey("bio") == true ? data!["bio"] : "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error getting user data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMyProfile = FirebaseAuth.instance.currentUser!.uid == widget.userId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        toolbarHeight: 250,
        leading: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.surface,
            ),
          ),
        ),
        title: Column(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/download.jpeg',
                height: 130,
                width: 130,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.surface,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              (bio!.isEmpty) ? 'Welcome in my Whale chat' : bio!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.surface,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          isMyProfile
              ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      );
                      getUserData();
                    },
                    icon: Icon(
                      Icons.edit,
                      color: colorScheme.surface,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
