import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String text;
  final bool isMe;
  final Timestamp? time;
  final String status;

  Message({
    required this.time,
    required this.text,
    required this.isMe,
    required this.status,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      text: data['text'],
      isMe: data['sender'] == FirebaseAuth.instance.currentUser!.uid,
      status: data['status'],
      time: data['time'] ?? Timestamp.now(),
    );
  }
}
