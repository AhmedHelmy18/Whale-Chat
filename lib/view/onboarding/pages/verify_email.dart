import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whale_chat/app.dart';
import 'package:whale_chat/services/user_service.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/onboarding/widgets/primary_button.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String name;

  const VerifyEmailPage({super.key, required this.email, required this.name});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool loading = false;

  Future<void> checkVerification() async {
    setState(() => loading = true);

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.email == widget.email) {
        if (user.emailVerified) {
          createUserDocument(
              uid: user.uid, name: widget.name, email: widget.email);
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainHome()),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email not verified yet.")),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("This email does not match your account.")),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No signed-in user found.")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
        child: Column(
          children: [
            const Text(
              'Please verify your email',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "We have sent a verification email to: ",
                    style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: widget.email,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Image.asset(
              "assets/images/emailVerify.png",
              height: 400,
              width: 400,
            ),
            const Spacer(),
            PrimaryButton(
              text: loading ? 'checkIn...' : 'Verify',
              onPressed: checkVerification,
              primaryButton: true,
              enabled: !loading,
            ),
          ],
        ),
      ),
    );
  }
}
