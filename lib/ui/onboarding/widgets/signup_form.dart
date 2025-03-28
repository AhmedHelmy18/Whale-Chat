import 'package:chat_app/ui/onboarding/pages/login_page.dart';
import 'package:chat_app/ui/onboarding/common/error_box.dart';
import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  String error = '';
  bool obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (error.isNotEmpty) ? ErrorBox(content: error) : const SizedBox(),
        TextField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: 'Name',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                (obscureText) ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: 'Password',
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (emailController.text.isEmpty ||
                  passwordController.text.isEmpty ||
                  nameController.text.isEmpty) {
                setState(() {
                  error = 'Please enter Name and Email and Password.';
                });
              } else {
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(credential.user?.uid)
                      .set({
                    'name': nameController.text,
                    'last conversation': [],
                    "fcm token": await FirebaseMessaging.instance.getToken(),
                  });
                  await credential.user?.sendEmailVerification();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                      (route) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    setState(() {
                      error = 'The password provided is too weak.';
                    });
                  } else if (e.code == 'email-already-in-use') {
                    setState(() {
                      error = 'The account already exists for that email.';
                    });
                  }
                } catch (e) {
                  setState(() {
                    error = e.toString();
                  });
                }
              }
            },
            child: Text(
              'Sign Up',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey,
                thickness: 1,
                endIndent: 10,
              ),
            ),
            Text('or'),
            Expanded(
              child: Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 10,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Text('Log in'),
          ),
        ),
      ],
    );
  }
}
