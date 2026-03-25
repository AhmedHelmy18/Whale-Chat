import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whale_chat/data/repository/status_repository.dart';
import 'package:whale_chat/model/status/status.dart';

void main() {
  test('Benchmark StatusRepository.addStatus performance (with provided profile)', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    final mockUser = MockUser(uid: 'user1');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockStorage = MockFirebaseStorage();

    // Pre-populate user profile in Firestore
    await fakeFirestore.collection('users').doc('user1').set({
      'name': 'John Doe',
      'image': 'profile.jpg',
    });

    final times = <int>[];

    // Measure baseline
    for (int i = 0; i < 50; i++) {
      final repository = StatusRepository(
        firestore: fakeFirestore,
        storage: mockStorage,
        auth: mockAuth,
      );

      final statusesSnapshot = await fakeFirestore.collection('statuses').get();
      for (var doc in statusesSnapshot.docs) {
        await fakeFirestore.collection('statuses').doc(doc.id).delete();
      }

      final watch = Stopwatch()..start();
      await repository.addStatus(
        type: StatusType.text,
        content: 'Status $i',
        backgroundColor: '#FF0000',
        userName: 'John Doe',
        userProfileImage: 'profile.jpg',
      );
      watch.stop();
      times.add(watch.elapsedMicroseconds);
    }

    // Discard the very first run which includes cold start overhead
    times.removeAt(0);

    print('Execution times (microseconds): $times');
    final average = times.reduce((a, b) => a + b) / times.length;
    print('Average time: $average microseconds');
  });
}
