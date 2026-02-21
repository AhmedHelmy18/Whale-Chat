import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/services/status_service.dart';

class StatusViewModel extends ChangeNotifier {
  final StatusService _statusService = StatusService();
  StreamSubscription? _statusesSubscription;
  StreamSubscription? _myStatusSubscription;

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
    _currentUserId = await _statusService.getCurrentUserId();
    notifyListeners();
  }

  void _listenToStatuses() {
    _statusesSubscription = _statusService.getStatuses().listen((newStatuses) {
      _statuses = newStatuses;
      notifyListeners();
    });

    _myStatusSubscription = _statusService.getMyStatus().listen((newMyStatus) {
      _myStatus = newMyStatus;
      notifyListeners();
    });
  }

  void _fetchCurrentUserImage() async {
    _currentUserImageUrl = await _statusService.getCurrentUserImageUrl();
    notifyListeners();
  }

  Future<void> addStatus({
    required StatusType type,
    required String content,
    String? caption,
    File? imageFile,
    String? backgroundColor,
  }) async {
    await _statusService.addStatus(
      type: type,
      content: content,
      caption: caption,
      imageFile: imageFile,
      backgroundColor: backgroundColor,
    );
  }

  Future<void> markStatusAsViewed(String statusId, String statusItemId) async {
    await _statusService.markStatusAsViewed(statusId, statusItemId);
  }

  Future<void> deleteStatus(String statusId) async {
    await _statusService.deleteStatus(statusId);
  }

  Future<void> deleteStatusItem(String statusId, String itemId) async {
    await _statusService.deleteStatusItem(statusId, itemId);
  }

  @override
  void dispose() {
    _statusesSubscription?.cancel();
    _myStatusSubscription?.cancel();
    super.dispose();
  }
}
