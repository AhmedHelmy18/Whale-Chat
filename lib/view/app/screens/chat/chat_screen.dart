import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whale_chat/app.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/chat/message_body_widget.dart';
import 'package:whale_chat/view/app/screens/profile/profile_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
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

  Future<String?> getProfileImage() async {
    try {
      final ref = FirebaseStorage.instance.ref('users/$userId/profile.jpg');
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const ChatApp()),
                (route) => false,
              );
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.surface,
              size: 24,
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(body: ProfileScreen(userId: userId)),
              ),
            );
          },
          child: Row(
            children: [
              Hero(
                tag: 'profile_$userId',
                child: FutureBuilder<String?>(
                  future: getProfileImage(),
                  builder: (context, snapshot) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: snapshot.data != null
                            ? Image.network(
                                snapshot.data!,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/download.jpeg',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.surface,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.surface.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.videocam_rounded,
              color: colorScheme.surface,
              size: 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.call_rounded,
              color: colorScheme.surface,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: MessageBodyWidget(
        conversationId: conversationId,
        userId: userId,
      ),
    );
  }
}
