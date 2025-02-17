import 'package:chat_app/constants/theme.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({
    super.key,
    required this.userName,
    required this.bio,
  });

  final String userName;
  final String? bio;

  @override
  Widget build(BuildContext context) {
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
              (bio == null) ? 'Welcome in my Whale chat' : bio!,
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
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.edit,
                color: colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
