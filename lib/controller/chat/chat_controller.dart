import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:whale_chat/model/message.dart';
import 'package:whale_chat/services/message_service.dart';

class ChatController {
  ChatController({required this.conversationId, required this.userId}) {
    init();
  }

  final String conversationId;
  final String userId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker();
  late final MessageService messageService;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ValueNotifier<List<Message>> messages = ValueNotifier<List<Message>>([]);
  final ValueNotifier<List<File>> pickedImages = ValueNotifier<List<File>>([]);

  StreamSubscription<QuerySnapshot>? _sub;

  void init() {
    messageService = MessageService(
      conversationId: conversationId,
      userId: userId,
    );
    _listenToMessages();
  }

  void _listenToMessages() {
    final myId = _auth.currentUser?.uid;
    if (myId == null) return;

    _sub = _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        return Message.fromDoc(doc: doc, myId: myId);
      }).toList();

      messages.value = list;
      scrollToBottom();
      messageService.updateDeliveredForIncoming();
      messageService.markMessagesAsSeen();
    });
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> pickMultiImages() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    final current = List<File>.from(pickedImages.value);
    current.addAll(files.map((e) => File(e.path)));
    pickedImages.value = current;
  }

  Future<void> pickSingleImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    final current = List<File>.from(pickedImages.value);
    current.add(File(file.path));
    pickedImages.value = current;
  }

  void removePickedImageAt(int index) {
    final current = List<File>.from(pickedImages.value);
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    pickedImages.value = current;
  }

  void clearPickedImages() {
    pickedImages.value = [];
  }

  Future<void> sendMessageWithMedia() async {
    final text = messageController.text.trim();
    final images = List<File>.from(pickedImages.value);

    if (text.isEmpty && images.isEmpty) return;

    await messageService.sendTextAndImages(
      text: text,
      images: images,
    );
    messageController.clear();
    clearPickedImages();
  }

  void dispose() {
    _sub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    messages.dispose();
    pickedImages.dispose();
  }
}
