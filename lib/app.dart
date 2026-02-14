import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/home/home_screen.dart';
import 'package:whale_chat/view/app/screens/profile/profile_screen.dart';
import 'package:whale_chat/view/onboarding/screens/onboarding/onboarding_screen.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = authSnapshot.data;

          if (user == null) {
            return const OnboardingScreen();
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, docSnapshot) {
              if (docSnapshot.hasError) {
                FirebaseAuth.instance.signOut();
                return const OnboardingScreen();
              }

              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
                return const OnboardingScreen();
              }

              return MainHome(userId: user.uid);
            },
          );
        },
      ),
    );
  }
}

class MainHome extends StatefulWidget {
  final String userId;

  const MainHome({super.key, required this.userId});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int selectedIndex = 0;

  late final List<Widget> pages = [
    const HomeScreen(),
    ProfileScreen(userId: widget.userId),
  ];

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
              color: colorScheme.primary.withValues(alpha: 0.9),
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
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: selectedIndex,
                selectedItemColor: colorScheme.surface,
                unselectedItemColor:
                colorScheme.onSurface.withValues(alpha: 0.6),
                onTap: (index) {
                  setState(() => selectedIndex = index);
                },
                selectedIconTheme: const IconThemeData(size: 28),
                unselectedIconTheme: const IconThemeData(size: 26),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 13),
                      child: Icon(Icons.chat_bubble_outline_rounded),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 13),
                      child: Icon(Icons.chat_bubble_rounded),
                    ),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 13),
                      child: Icon(Icons.account_circle_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 13),
                      child: Icon(Icons.account_circle),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
