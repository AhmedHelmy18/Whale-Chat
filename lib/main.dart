import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/home_page.dart';
import 'package:chat_app/ui/onboarding/pages/onboarding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if(kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator("10.0.2.2", 9099);
    FirebaseFirestore.instance.useFirestoreEmulator("10.0.2.2", 8080);
    FirebaseFunctions.instance.useFunctionsEmulator("10.0.2.2", 5001);
  }

  runApp(
    const ChatApp(),
  );
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});


  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null;
      });
    });
    FirebaseMessaging.instance.requestPermission();
  }


  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return MaterialApp(
      key: scaffoldKey,
      theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomePage() : const OnboardingPage(),
    );
  }
}
