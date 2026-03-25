import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:whale_chat/data/repository/user_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

void main() {
  late UserRepository userRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockFirebaseFunctions mockFunctions;
  late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
  late MockQuery<Map<String, dynamic>> mockQuery1;
  late MockQuery<Map<String, dynamic>> mockQuery2;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockFunctions = MockFirebaseFunctions();
    mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery1 = MockQuery<Map<String, dynamic>>();
    mockQuery2 = MockQuery<Map<String, dynamic>>();

    userRepository = UserRepository(
      firestore: mockFirestore,
      storage: mockStorage,
      functions: mockFunctions,
    );

    // Setup basic mock returns
    when(() => mockFirestore.collection('users'))
        .thenReturn(mockUsersCollection);
  });

  group('UserRepository searchUsers', () {
    test('returns empty list when query is empty', () async {
      final result = await userRepository.searchUsers('');
      expect(result, isEmpty);

      final resultWithSpaces = await userRepository.searchUsers('   ');
      expect(resultWithSpaces, isEmpty);
    });

    test('returns empty list when an exception is thrown', () async {
      const query = 'test';

      when(() => mockUsersCollection.where('name',
              isGreaterThanOrEqualTo: query))
          .thenReturn(mockQuery1);
      when(() => mockQuery1.where('name', isLessThan: '${query}z'))
          .thenReturn(mockQuery2);
      when(() => mockQuery2.get()).thenThrow(Exception('Firestore error'));

      final result = await userRepository.searchUsers(query);

      expect(result, isEmpty);
      verify(() => mockQuery2.get()).called(1);
    });
  });
}
