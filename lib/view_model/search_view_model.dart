import 'package:flutter/foundation.dart';
import 'package:whale_chat/data/model/user_model.dart';
import 'package:whale_chat/data/repository/chat_repository.dart';
import 'package:whale_chat/data/repository/user_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final ChatRepository _chatRepository = ChatRepository();

  List<UserModel> _searchResults = [];
  List<UserModel> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCreatingChat = false;
  bool get isCreatingChat => _isCreatingChat;

  Future<void> searchUsers(String query, String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    final results = await _userRepository.searchUsers(query);
    _searchResults = results.where((user) => user.id != currentUserId).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createChat(String participantId) async {
    _isCreatingChat = true;
    notifyListeners();
    try {
      return await _chatRepository.createChat(participantId);
    } catch (_) {
      return null;
    } finally {
      _isCreatingChat = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
