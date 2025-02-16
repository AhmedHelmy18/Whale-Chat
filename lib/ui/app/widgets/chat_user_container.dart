import 'package:chat_app/constants/format_time.dart';
import 'package:chat_app/ui/app/pages/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatUserContainer extends StatelessWidget {
  const ChatUserContainer({
    super.key,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.conversationId,
  });

  final String userId;
  final String userName;
  final String lastMessage;
  final Timestamp? timestamp;
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              userId: userId,
              userName: userName,
              conversationId: conversationId,
            ),
          ),
        );
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/download.jpeg',
                  height: 70,
                ),
                SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
                Text(
                  formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
