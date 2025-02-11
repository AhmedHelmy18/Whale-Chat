import 'package:chat_app/ui/onboarding/pages/verify_email.dart';
import 'package:chat_app/constants//theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Forget Password',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
          ),
          Text(
            'Please enter your email address to reset your password.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextField(
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
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 30,
            child: TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  if(emailController.text.isEmpty){
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter your email address.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailController.text);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerifyEmail(),
                    ),
                  );
                } catch (e) {
                  DialogRoute(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text(
                'Reset Password',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
