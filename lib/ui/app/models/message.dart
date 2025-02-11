import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final bool isMe;
  // final Timestamp time;

  Message({
    // required this.time,
    required this.text,
    required this.isMe,
  });
}
