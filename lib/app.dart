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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    currentIndex: selectedIndex,
                    selectedItemColor: colorScheme.surface,
                    unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
                    onTap: (index) => setState(() => selectedIndex = index),
                    selectedIconTheme: const IconThemeData(size: 28),
                    unselectedIconTheme: const IconThemeData(size: 26),
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(top: 13.0),
                          child: Icon(Icons.chat_bubble_outline_rounded),
                        ),
                        activeIcon: Padding(
                          padding: EdgeInsets.only(top: 13.0),
                          child: Icon(Icons.chat_bubble_rounded),
                        ),
                        label: 'Chats',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle_outlined),
                        activeIcon: Icon(Icons.account_circle),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
