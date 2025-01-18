import 'package:chat_app/auth/pages/onboarding_page.dart';
import 'package:chat_app/theme.dart';
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
    return MaterialApp(
        theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
        debugShowCheckedModeBanner: false,
      home: OnboardingPage(),
    );
  }
}