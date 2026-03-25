import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whale_chat/data/model/user_model.dart';
import 'package:whale_chat/data/repository/user_repository.dart';
import 'package:whale_chat/view_model/profile_view_model.dart';

@GenerateMocks([UserRepository])
import 'profile_view_model_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late ProfileViewModel viewModel;

  setUp(() {
    mockUserRepository = MockUserRepository();
    viewModel = ProfileViewModel(userRepository: mockUserRepository);
  });

  group('ProfileViewModel', () {
    final testUser = UserModel(
      id: 'test_uid',
      name: 'Test User',
      email: 'test@example.com',
      about: 'Test About',
      image: 'http://test-image.com/img.jpg',
      isOnline: true,
      pushToken: 'test_token',
    );

    test('loadProfile updates state correctly when user is found', () async {
      when(mockUserRepository.getUser('test_uid')).thenAnswer((_) async => testUser);

      expect(viewModel.isLoading, false);
      expect(viewModel.user, null);

      final future = viewModel.loadProfile('test_uid');

      expect(viewModel.isLoading, true);

      await future;

      expect(viewModel.isLoading, false);
      expect(viewModel.user, testUser);
      verify(mockUserRepository.getUser('test_uid')).called(1);
    });

    test('loadProfile updates state correctly when user is null', () async {
      when(mockUserRepository.getUser('test_uid')).thenAnswer((_) async => null);

      expect(viewModel.isLoading, false);
      expect(viewModel.user, null);

      final future = viewModel.loadProfile('test_uid');

      expect(viewModel.isLoading, true);

      await future;

      expect(viewModel.isLoading, false);
      expect(viewModel.user, null);
      verify(mockUserRepository.getUser('test_uid')).called(1);
    });

    test('updateProfile sets isSaving to true and updates user locally on success', () async {
      // First load a profile so we have a user
      when(mockUserRepository.getUser('test_uid')).thenAnswer((_) async => testUser);
      await viewModel.loadProfile('test_uid');

      when(mockUserRepository.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: 'http://new-image.com/img.jpg',
      )).thenAnswer((_) async => true);

      expect(viewModel.isSaving, false);

      final future = viewModel.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: 'http://new-image.com/img.jpg',
      );

      expect(viewModel.isSaving, true);

      final success = await future;

      expect(success, true);
      expect(viewModel.isSaving, false);
      expect(viewModel.user?.name, 'New Name');
      expect(viewModel.user?.about, 'New About');
      expect(viewModel.user?.image, 'http://new-image.com/img.jpg');

      verify(mockUserRepository.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: 'http://new-image.com/img.jpg',
      )).called(1);
    });

    test('updateProfile keeps old image if imageUrl is null', () async {
      // First load a profile so we have a user
      when(mockUserRepository.getUser('test_uid')).thenAnswer((_) async => testUser);
      await viewModel.loadProfile('test_uid');

      when(mockUserRepository.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: null,
      )).thenAnswer((_) async => true);

      final success = await viewModel.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: null,
      );

      expect(success, true);
      expect(viewModel.user?.name, 'New Name');
      expect(viewModel.user?.about, 'New About');
      expect(viewModel.user?.image, 'http://test-image.com/img.jpg'); // Image stays the same

      verify(mockUserRepository.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: null,
      )).called(1);
    });

    test('updateProfile does not update user locally on failure', () async {
      // First load a profile so we have a user
      when(mockUserRepository.getUser('test_uid')).thenAnswer((_) async => testUser);
      await viewModel.loadProfile('test_uid');

      when(mockUserRepository.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: 'http://new-image.com/img.jpg',
      )).thenAnswer((_) async => false);

      final success = await viewModel.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: 'http://new-image.com/img.jpg',
      );

      expect(success, false);
      expect(viewModel.user?.name, 'Test User'); // Old name
      expect(viewModel.user?.about, 'Test About'); // Old about
      expect(viewModel.user?.image, 'http://test-image.com/img.jpg'); // Old image

      verify(mockUserRepository.updateProfile(
        name: 'New Name',
        about: 'New About',
        imageUrl: 'http://new-image.com/img.jpg',
      )).called(1);
    });
  });
}
