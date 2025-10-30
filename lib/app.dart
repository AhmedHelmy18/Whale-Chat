import 'package:chat_app/theme/color_scheme.dart';
import 'package:chat_app/view/app/pages/home_page.dart';
import 'package:chat_app/view/app/pages/profile.dart';
import 'package:chat_app/view/onboarding/pages/onboarding_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  bool isLoggedIn = false;
  int selectedIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;

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

  late final List<Widget> pages = [
    HomePage(),
    ProfilePage(
      userId: auth.currentUser!.uid,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? Scaffold(
              body: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
              bottomNavigationBar: SizedBox(
                height: 100,
                child: BottomNavigationBar(
                  backgroundColor: colorScheme.primary,
                  selectedItemColor: colorScheme.surface,
                  unselectedItemColor: colorScheme.onSurface,
                  currentIndex: selectedIndex,
                  onTap: _onItemTapped,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  selectedIconTheme: const IconThemeData(size: 30),
                  unselectedIconTheme: const IconThemeData(size: 25),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'My Profile',
                    ),
                  ],
                ),
              ),
            )
          : const OnboardingPage(),
    );
  }
}
