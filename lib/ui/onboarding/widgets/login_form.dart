import 'package:chat_app/ui/onboarding/pages/forget_password.dart';
import 'package:chat_app/ui/onboarding/pages/sign_up_page.dart';
import 'package:chat_app/ui/onboarding/common//error_box.dart';
import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String error = '';
  bool obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (error.isNotEmpty) ? ErrorBox(content: error) : const SizedBox(),
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
        const SizedBox(height: 15),
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgetPassword(),
                ),
              );
            },
            child: Text(
              'Forgot Password?',
            ),
          ),
        ),
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
                  passwordController.text.isEmpty) {
                setState(() {
                  error = 'please enter valid email or password';
                });
              } else {
                try {
                  final credential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    setState(() {
                      error = 'No user found for that email.';
                    });
                  } else if (e.code == 'wrong-password') {
                    setState(() {
                      error = 'Wrong password provided for that user.';
                    });
                  }
                }
              }
            },
            child: Text(
              'Log in',
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
                  builder: (context) => SignUpPage(),
                ),
              );
            },
            child: Text('Sign up'),
          ),
        ),
      ],
    );
  }
}
