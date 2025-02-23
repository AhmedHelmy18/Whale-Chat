import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/home_page.dart';
import 'package:chat_app/ui/app/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({
    super.key,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int tabIndex = 0;
  String userName = "";
  String bio = "";
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        setState(() {
          userName = userSnapshot["name"] ?? "Unknown";
          bio = userSnapshot["bio"] ?? "No bio available";
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: colorScheme.primary,
      selectedItemColor: colorScheme.surface,
      unselectedItemColor: colorScheme.onSurface,
      onTap: (index) {
        setState(() => tabIndex = index);
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(

              ),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(
                userId: userId,
              ),
            ),
          );
        }
        setState(() => tabIndex = 0);
      },
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
      currentIndex: tabIndex,
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
    );
  }
}
