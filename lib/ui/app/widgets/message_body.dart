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
        .doc('Tj0bgkutWrJOnAeCQMJ9')
        .collection('messages')
        .add({
      'text': _messageController.text,
      'sender': FirebaseAuth.instance.currentUser!.uid,
      'time': FieldValue.serverTimestamp(),
    });
    _messageController.clear();
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('conversations')
        .doc('Tj0bgkutWrJOnAeCQMJ9')
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<Message> updatedMessages = [];

      for (var doc in snapshot.docs) {
        updatedMessages.add(
          Message(
            text: doc['text'],
            isMe: doc['sender'] == FirebaseAuth.instance.currentUser!.uid,
            // time: doc['time'],
          ),
        );
      }
      setState(() {
        messages =
            updatedMessages;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), // Smooth scroll
          curve: Curves.easeOut,
        );
      });

    });
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
              return Align(
                alignment:
                    message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: width * 0.65,
                      minWidth: 50,
                    ),
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      right: message.isMe ? 10 : 0,
                      left: message.isMe ? 0 : 10,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMe
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomLeft:
                            message.isMe ? Radius.circular(20) : Radius.zero,
                        topRight:
                            message.isMe ? Radius.zero : Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.surface,
                      ),
                    ),
                  ),
                ),
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
