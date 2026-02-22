import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whale_chat/data/model/message.dart';
import 'package:whale_chat/data/repository/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final ImagePicker _picker = ImagePicker();

  final String conversationId;
  final String currentUserId;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  List<File> _pickedImages = [];
  List<File> get pickedImages => _pickedImages;

  bool _isSending = false;
  bool get isSending => _isSending;

  StreamSubscription? _messageSubscription;

  ChatViewModel({required this.conversationId, required this.currentUserId}) {
    _listenToMessages();
  }

  void _listenToMessages() {
    _messageSubscription = _chatRepository
        .getMessages(conversationId, currentUserId)
        .listen((msgs) {
      _messages = msgs;
      notifyListeners();

      // Update delivered status for incoming messages
      _chatRepository.updateMessageStatus(
        conversationId: conversationId,
        status: 'delivered',
      );
    });
  }

  // Mark as seen when user views the chat
  void markAsSeen() {
    _chatRepository.updateMessageStatus(
      conversationId: conversationId,
      status: 'seen',
    );
  }

  Future<void> sendMessage(String text) async {
    if (_isSending) return;

    _isSending = true;
    final imagesToSend = List<File>.from(_pickedImages);
    _pickedImages = []; // Clear immediately
    notifyListeners();

    try {
      await _chatRepository.sendMessage(
        conversationId: conversationId,
        senderId: currentUserId,
        text: text,
        images: imagesToSend,
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> pickMultiImages() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    _pickedImages.addAll(files.map((e) => File(e.path)));
    notifyListeners();
  }

  Future<void> pickSingleImage(ImageSource source) async {
    final XFile? file =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    _pickedImages.add(File(file.path));
    notifyListeners();
  }

  void removePickedImageAt(int index) {
    if (index >= 0 && index < _pickedImages.length) {
      _pickedImages.removeAt(index);
      notifyListeners();
    }
  }

  void clearPickedImages() {
    _pickedImages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
