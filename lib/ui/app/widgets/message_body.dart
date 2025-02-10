import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/models/message.dart';
import 'package:flutter/material.dart';

class MessageBody extends StatefulWidget {
  const MessageBody({super.key});

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  void sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(Message(text: _messageController.text.trim(), isMe: true));
        _messageController.clear();

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            messages.add(Message(text: 'This is a reply!', isMe: false));
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
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
