import 'package:flutter/material.dart';

void main() {
  runApp(
    const ChatApp(),
  );
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Text("Chat App"),
    );
  }
}