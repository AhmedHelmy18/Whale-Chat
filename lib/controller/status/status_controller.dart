import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/services/status_service.dart';

class StatusController {
  final StatusService _statusService = StatusService();
  StreamSubscription? _statusesSubscription;
  StreamSubscription? _myStatusSubscription;

  final ValueNotifier<List<Status>> statuses = ValueNotifier<List<Status>>([]);
  final ValueNotifier<Status?> myStatus = ValueNotifier<Status?>(null);
  final ValueNotifier<String?> currentUserImageUrl =
      ValueNotifier<String?>(null);
  final ValueNotifier<String?> currentUserId = ValueNotifier<String?>(null);

  // Getter for status list
  ValueNotifier<List<Status>> get statusList => statuses;

  void init() {
    _listenToStatuses();
    _fetchCurrentUserImage();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    currentUserId.value = await _statusService.getCurrentUserId();
  }

  void _listenToStatuses() {
    _statusesSubscription = _statusService.getStatuses().listen((newStatuses) {
      statuses.value = newStatuses;
    });

    _myStatusSubscription = _statusService.getMyStatus().listen((newMyStatus) {
      myStatus.value = newMyStatus;
    });
  }

  void _fetchCurrentUserImage() async {
    currentUserImageUrl.value = await _statusService.getCurrentUserImageUrl();
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

  void dispose() {
    _statusesSubscription?.cancel();
    _myStatusSubscription?.cancel();
    statuses.dispose();
    myStatus.dispose();
    currentUserImageUrl.dispose();
    currentUserId.dispose();
  }
}
