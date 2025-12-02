import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/pages/home_page.dart';
import 'package:whale_chat/view/app/pages/profile.dart';
import 'package:whale_chat/view/onboarding/pages/onboarding_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = authSnapshot.data;

          if (user == null) {
            return const OnboardingPage();
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              final userExists = docSnapshot.data?.exists ?? false;
              if (!userExists) {
                return const OnboardingPage();
              }
              return const MainHome();
            },
          );
        },
      ),
    );
  }
}

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    const HomePage(),
    ProfilePage(userId: FirebaseAuth.instance.currentUser!.uid),
  ];

  void onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 125,
        child: BottomNavigationBar(
          backgroundColor: colorScheme.primary,
          selectedItemColor: colorScheme.surface,
          unselectedItemColor: colorScheme.onSurface,
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          selectedIconTheme: const IconThemeData(size: 30),
          unselectedIconTheme: const IconThemeData(size: 25),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
