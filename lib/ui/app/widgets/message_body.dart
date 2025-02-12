import 'package:chat_app/constants/format_time.dart';
import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageBody extends StatefulWidget {
  const MessageBody({super.key});

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];

  void sendMessage() {
    FirebaseFirestore.instance
        .collection('conversations')
        .doc('G7TWiVqwRnZX3CP2xK87')
        .collection('Messages')
        .add({
      'text': _messageController.text,
      'sender': FirebaseAuth.instance.currentUser!.uid,
      'time': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
    _messageController.clear();
  }

  void markMessagesAsSeen() {
    FirebaseFirestore.instance
        .collection('conversations')
        .doc('G7TWiVqwRnZX3CP2xK87')
        .collection('Messages')
        .where('status', isEqualTo: 'delivered')
        .where('sender', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'status': 'seen'});
      }
    });
  }

  Icon getMessageStatusIcon(String status) {
    if (status == 'sent') {
      return Icon(Icons.check, color: Colors.grey, size: 16);
    } else if (status == 'delivered') {
      return Icon(Icons.done_all, color: Colors.grey, size: 16);
    } else if (status == 'seen') {
      return Icon(Icons.done_all, color: Colors.blue, size: 16);
    }
    return Icon(Icons.check, color: Colors.grey, size: 16);
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('conversations')
        .doc('G7TWiVqwRnZX3CP2xK87')
        .collection('Messages')
        .orderBy('time', descending: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<Message> updatedMessages = [];

      for (var doc in snapshot.docs) {
        updatedMessages
            .add(Message.fromFirestore(doc.data() as Map<String, dynamic>));

        if (doc['status'] == 'sent' &&
            doc['sender'] != FirebaseAuth.instance.currentUser!.uid) {
          doc.reference.update({'status': 'delivered'});
        }
      }
      setState(() {
        messages = updatedMessages;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
    markMessagesAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final message = messages[index];
              return Column(
                children: [
                  if (index == 0)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 40,
                          minWidth: 50,
                          maxWidth: 80,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            formatDate(messages[index].time),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: message.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: IntrinsicWidth(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: width * 0.65,
                          minWidth: 50,
                        ),
                        margin: EdgeInsets.only(
                          top: 10,
                          right: message.isMe ? 10 : 0,
                          left: message.isMe ? 0 : 10,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: message.isMe
                              ? colorScheme.primary
                              : colorScheme.secondary,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                            bottomLeft: message.isMe
                                ? Radius.circular(20)
                                : Radius.zero,
                            topRight: message.isMe
                                ? Radius.zero
                                : Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.surface,
                              ),
                            ),
                            Align(
                              alignment: message.isMe
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                              child: Row(
                                children: [
                                  Text(
                                    formatTimestamp(message.time),
                                    style: TextStyle(
                                      color: colorScheme.surface,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  getMessageStatusIcon(message.status),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 10,
                    right: 8,
                    bottom: 20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    controller: _messageController,
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      constraints: BoxConstraints(
                        maxWidth: 50,
                        minHeight: 50,
                        maxHeight: height / 4,
                      ),
                      hintText: 'Message',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  right: 10,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: colorScheme.surface,
                  ),
                  onPressed: sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
