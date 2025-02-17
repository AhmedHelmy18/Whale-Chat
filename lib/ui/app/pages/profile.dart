import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({
    super.key,
    required this.userName,
    required this.bio,
    required this.userId,
  });

  final String userName;
  final String? bio;
  final String userId;

  @override
  Widget build(BuildContext context) {
    bool isMyProfile = FirebaseAuth.instance.currentUser!.uid == userId;
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
          isMyProfile ? Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfile(),
                  ),
                );
              },
              icon: Icon(
                Icons.edit,
                color: colorScheme.surface,
              ),
            ),
          ): Container(),
        ],
      ),
    );
  }
}
