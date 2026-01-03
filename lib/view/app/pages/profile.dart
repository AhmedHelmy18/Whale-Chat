import 'package:flutter/material.dart';
import 'package:whale_chat/controller/profile/profile_controller.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/pages/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userId});

  final String userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = ProfileController();

  String userName = "";
  String? bio = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final data = await controller.getUserData(widget.userId);
    if (!mounted) return;

    setState(() {
      userName = data?['name'] ?? "You";
      bio = data?['bio'] ?? "";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyProfile = FirebaseAuth.instance.currentUser?.uid == widget.userId;

    return Container(
      color: colorScheme.primary,
      height: 250,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              ClipOval(
                child: Image.asset(
                  'assets/images/download.jpeg',
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.surface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                (bio?.isEmpty ?? true)
                    ? 'Welcome in my Whale chat'
                    : bio!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.surface,
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 20,
                ),
              ),
            ],
          ),
          if (!isMyProfile)
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                onPressed: () {
                  if (mounted) Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios,
                    color: colorScheme.surface),
              ),
            ),
          if (isMyProfile)
            Positioned(
              top: 40,
              right: 10,
              child: IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                  if (!mounted) return;
                  loadUserData();
                },
                icon: Icon(Icons.edit, color: colorScheme.surface),
              ),
            ),
        ],
      ),
    );
  }
}
