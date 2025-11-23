import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/pages/home_page.dart';
import 'package:whale_chat/view/app/pages/profile.dart';
import 'package:whale_chat/view/onboarding/pages/onboarding_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:whale_chat/view/onboarding/pages/verify_email.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  bool isLoggedIn = false;
  bool isFirestoreChecked = false;
  bool hasUserData = false;
  int selectedIndex = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        setState(() {
          isLoggedIn = true;
          isFirestoreChecked = false;
        });

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          hasUserData = userDoc.exists;
          isFirestoreChecked = true;
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    });
  }

  late final List<Widget> pages = [
    HomePage(),
    ProfilePage(
      userId: auth.currentUser!.uid,
    ),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: VerifyEmailPage(
          email: '',
          name: '',
        ));
    //   (isLoggedIn && hasUserData)
    //       ? Scaffold(
    //           body: IndexedStack(
    //             index: selectedIndex,
    //             children: pages,
    //           ),
    //           bottomNavigationBar: SizedBox(
    //             height: 125,
    //             child: BottomNavigationBar(
    //               backgroundColor: colorScheme.primary,
    //               selectedItemColor: colorScheme.surface,
    //               unselectedItemColor: colorScheme.onSurface,
    //               currentIndex: selectedIndex,
    //               onTap: onItemTapped,
    //               selectedLabelStyle: const TextStyle(
    //                 fontWeight: FontWeight.w500,
    //                 fontSize: 18,
    //               ),
    //               unselectedLabelStyle: const TextStyle(
    //                 fontWeight: FontWeight.w500,
    //                 fontSize: 16,
    //               ),
    //               selectedIconTheme: const IconThemeData(size: 30),
    //               unselectedIconTheme: const IconThemeData(size: 25),
    //               items: const [
    //                 BottomNavigationBarItem(
    //                   icon: Icon(Icons.home),
    //                   label: 'Home',
    //                 ),
    //                 BottomNavigationBarItem(
    //                   icon: Icon(Icons.person),
    //                   label: 'Profile',
    //                 ),
    //               ],
    //             ),
    //           ),
    //         )
    //       : const OnboardingPage(),
    // );
  }
}
