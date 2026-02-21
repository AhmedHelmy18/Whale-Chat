import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/data/repository/status_repository.dart';

class StatusViewModel extends ChangeNotifier {
  final StatusRepository _statusRepository = StatusRepository();
  StreamSubscription? _statusesSubscription;
  StreamSubscription? _myStatusSubscription;
  StreamSubscription? _userImageSubscription;

  List<Status> _statuses = [];
  Status? _myStatus;
  String? _currentUserImageUrl;
  String? _currentUserId;

  List<Status> get statuses => _statuses;
  Status? get myStatus => _myStatus;
  String? get currentUserImageUrl => _currentUserImageUrl;
  String? get currentUserId => _currentUserId;

  void init() {
    _listenToStatuses();
    _fetchCurrentUserImage();
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

  void _fetchCurrentUserImage() {
    _userImageSubscription =
        _statusRepository.getCurrentUserImageUrl().listen((imageUrl) {
      _currentUserImageUrl = imageUrl;
      notifyListeners();
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
    _userImageSubscription?.cancel();
    super.dispose();
  }
}
