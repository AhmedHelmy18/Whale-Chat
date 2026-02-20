import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:whale_chat/data/model/user_model.dart';
import 'package:whale_chat/data/repository/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    _user = await _userRepository.getUser(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String about,
    String? imageUrl,
  }) async {
    _isSaving = true;
    notifyListeners();
    final success = await _userRepository.updateProfile(
      name: name,
      about: about,
      imageUrl: imageUrl,
    );
    if (success && _user != null) {
       // Refresh user data locally if needed, or rely on fetching again
       // Since we don't return the updated model from updateProfile, we might need to fetch it again or optimistically update.
       // Here we rely on calling loadProfile again or stream if we implemented one.
       // However, to keep it simple, let's just update the local model fields if success.
       // But image update might be tricky if we don't have the URL here (if it was passed as imageUrl, we have it).
       // If imageUrl is null, we keep the old one.
       _user = UserModel(
         id: _user!.id,
         name: name,
         email: _user!.email,
         about: about,
         image: imageUrl ?? _user!.image,
         isOnline: _user!.isOnline,
         pushToken: _user!.pushToken,
       );
    }
    _isSaving = false;
    notifyListeners();
    return success;
  }

  Future<String?> uploadImage(String uid, File file) async {
    return await _userRepository.uploadProfileImage(uid, file);
  }
}
