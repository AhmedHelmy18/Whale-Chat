import 'package:cloud_firestore/cloud_firestore.dart';

class Status {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final List<StatusItem> statusItems;
  final DateTime createdAt;

  Status({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.statusItems,
    required this.createdAt,
  });

  factory Status.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Status(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userProfileImage: data['userProfileImage'],
      statusItems: (data['statusItems'] as List<dynamic>?)
          ?.map((item) => StatusItem.fromMap(item as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'statusItems': statusItems.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return now.difference(createdAt).inHours < 24;
  }

  StatusItem? get latestItem {
    if (statusItems.isEmpty) return null;
    return statusItems.last;
  }

  int unseenCount(String currentUserId) {
    return statusItems.where((item) => !item.viewedBy.contains(currentUserId)).length;
  }
}

class StatusItem {
  final String id;
  final String content;
  final StatusType type;
  final String? caption;
  final DateTime timestamp;
  final List<String> viewedBy;
  final String? backgroundColor;

  StatusItem({
    required this.id,
    required this.content,
    required this.type,
    this.caption,
    required this.timestamp,
    this.viewedBy = const [],
    this.backgroundColor,
  });

  factory StatusItem.fromMap(Map<String, dynamic> map) {
    return StatusItem(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      type: StatusType.values.firstWhere(
            (e) => e.toString() == 'StatusType.${map['type']}',
        orElse: () => StatusType.text,
      ),
      caption: map['caption'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
      backgroundColor: map['backgroundColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'caption': caption,
      'timestamp': Timestamp.fromDate(timestamp),
      'viewedBy': viewedBy,
      'backgroundColor': backgroundColor,
    };
  }
}

enum StatusType {
  text,
  image,
  video,
}