import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/data/repository/status_repository.dart';

class StatusViewModel extends ChangeNotifier {
  final StatusRepository _statusRepository = StatusRepository();
  StreamSubscription? _statusesSubscription;
  StreamSubscription? _myStatusSubscription;
  StreamSubscription? _userProfileSubscription;

  List<Status> _statuses = [];
  Status? _myStatus;
  String? _currentUserName;
  String? _currentUserImageUrl;
  String? _currentUserId;

  List<Status> get statuses => _statuses;
  Status? get myStatus => _myStatus;
  String? get currentUserName => _currentUserName;
  String? get currentUserImageUrl => _currentUserImageUrl;
  String? get currentUserId => _currentUserId;

  void init() {
    _listenToStatuses();
    _fetchCurrentUserProfile();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    _currentUserId = await _statusRepository.getCurrentUserId();
    notifyListeners();
  }

  void _listenToStatuses() {
    _statusesSubscription =
        _statusRepository.getStatuses().listen((newStatuses) {
      _statuses = newStatuses;
      notifyListeners();
    });

    _myStatusSubscription =
        _statusRepository.getMyStatus().listen((newMyStatus) {
      _myStatus = newMyStatus;
      notifyListeners();
    });
  }

  void _fetchCurrentUserProfile() {
    _userProfileSubscription =
        _statusRepository.getCurrentUserProfile().listen((userProfile) {
      if (userProfile != null) {
        _currentUserName = userProfile['name'];
        _currentUserImageUrl = userProfile['image'];
        notifyListeners();
      }
    });
  }

  Future<void> addStatus({
    required StatusType type,
    required String content,
    String? caption,
    File? imageFile,
    String? backgroundColor,
  }) async {
    await _statusRepository.addStatus(
      type: type,
      content: content,
      caption: caption,
      imageFile: imageFile,
      backgroundColor: backgroundColor,
      userName: _currentUserName,
      userProfileImage: _currentUserImageUrl,
    );
  }

  Future<void> markStatusAsViewed(String statusId, String statusItemId) async {
    await _statusRepository.markStatusAsViewed(statusId, statusItemId);
  }

  Future<void> deleteStatus(String statusId) async {
    await _statusRepository.deleteStatus(statusId);
  }

  Future<void> deleteStatusItem(String statusId, String itemId) async {
    await _statusRepository.deleteStatusItem(statusId, itemId);
  }

  @override
  void dispose() {
    _statusesSubscription?.cancel();
    _myStatusSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}
