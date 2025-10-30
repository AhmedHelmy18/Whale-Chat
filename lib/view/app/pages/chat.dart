import 'package:chat_app/theme/color_scheme.dart';
import 'package:chat_app/view/app/pages/profile.dart';
import 'package:chat_app/view/app/widgets/message_body.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  const Chat({
    super.key,
    required this.userId,
    required this.userName,
    required this.conversationId,
    required this.bio,
  });

  final String userId;
  final String userName;
  final String conversationId;
  final String? bio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: colorScheme.primary,
        leading: SizedBox(
          width: 60,
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
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userId: userId,
                ),
              ),
            );
          },
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/download.jpeg',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: MessageBody(
        conversationId: conversationId,
        userId: userId,
      ),
    );
  }
}
