import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whale_chat/model/status/status.dart';

void main() {
  group('Status Model', () {
    test('StatusItem fromMap should parse correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 'item1',
        'content': 'Test Content',
        'type': 'text',
        'caption': 'Caption',
        'timestamp': Timestamp.fromDate(now),
        'viewedBy': ['user1'],
        'backgroundColor': '#FF0000',
      };

      final item = StatusItem.fromMap(map);

      expect(item.id, 'item1');
      expect(item.content, 'Test Content');
      expect(item.type, StatusType.text);
      expect(item.caption, 'Caption');
      expect(item.timestamp, now);
      expect(item.viewedBy, contains('user1'));
      expect(item.backgroundColor, '#FF0000');
    });

    test('StatusItem toMap should serialize correctly', () {
      final now = DateTime.now();
      final item = StatusItem(
        id: 'item1',
        content: 'Test Content',
        type: StatusType.text,
        caption: 'Caption',
        timestamp: now,
        viewedBy: ['user1'],
        backgroundColor: '#FF0000',
      );

      final map = item.toMap();

      expect(map['id'], 'item1');
      expect(map['content'], 'Test Content');
      expect(map['type'], 'text');
      expect(map['caption'], 'Caption');
      expect(map['timestamp'], isA<Timestamp>());
      expect(map['viewedBy'], contains('user1'));
      expect(map['backgroundColor'], '#FF0000');
    });
  });
}
