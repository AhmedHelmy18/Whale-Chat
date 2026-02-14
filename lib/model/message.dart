import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final bool isMe;
  final String status;
  final Timestamp? time;
  final List<String> imageUrls;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.isMe,
    required this.status,
    required this.time,
    required this.imageUrls,
  });

  factory Message.fromDoc({required QueryDocumentSnapshot doc, required String myId}) {
    final data = doc.data() as Map<String, dynamic>;

    final images = data['imageUrls'];
    final singleImage = data['imageUrl'];

    List<String> urls = [];

    if (images is List) {
      urls = images.map((e) => e.toString()).toList();
    } else if (singleImage is String && singleImage.isNotEmpty) {
      urls = [singleImage];
    }

    return Message(
      id: doc.id,
      text: (data['content'] ?? '').toString(),
      senderId: (data['senderId'] ?? '').toString(),
      isMe: (data['senderId'] ?? '') == myId,
      status: (data['status'] ?? 'sent').toString(),
      time: data['sentAt'] is Timestamp ? data['sentAt'] as Timestamp : null,
      imageUrls: urls,
    );
  }
}
