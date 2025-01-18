import 'package:chat_app/auth/pages/onboarding_page.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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