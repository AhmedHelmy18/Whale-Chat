import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:whale_chat/data/repository/chat_repository.dart';
import 'package:whale_chat/data/repository/user_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final UserRepository _userRepository = UserRepository();

  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> get chats => _chats;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription? _chatSubscription;
  bool _isDisposed = false;

  void listenToChats(String userId) {
    _isLoading = true;
    notifyListeners();

    _chatSubscription = _chatRepository.getChats(userId).listen((
      chatModels,
    ) async {
      if (_isDisposed) return;
      final List<Map<String, dynamic>> loadedChats = [];

      // Optimized: Fetch users concurrently instead of sequentially
      final userFutures = chatModels.map((chat) async {
        final otherUserId = chat.participants.firstWhere(
          (id) => id != userId,
          orElse: () => '',
        );

        if (otherUserId.isNotEmpty) {
          final user = await _userRepository.getUser(otherUserId);
          if (user != null) {
            return {
              "id": chat.id,
              "userId": otherUserId,
              "name": user.name,
              "about": user.about,
              "lastMessage": chat.lastMessage,
              "timestamp": chat.lastMessageTime,
              "photoUrl": user.image, // Use image from User document
            };
          }
        }
        return null;
      });

      final results = await Future.wait(userFutures);
      for (var result in results) {
        if (result != null) {
          loadedChats.add(result);
        }
      }

      // Sort by timestamp
      loadedChats.sort((a, b) {
        final aTimestamp = a['timestamp'];
        final bTimestamp = b['timestamp'];
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;
        return bTimestamp.compareTo(aTimestamp);
      });

      _chats = loadedChats;
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _chatSubscription?.cancel();
    super.dispose();
  }
}
