import 'package:chat_app/auth/onboarding/login_form.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: screenHeight / 2 - 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              children: [
                Container(
                  height: screenHeight / 2 - 200,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(
                        "Login to your account",
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                        ),
                      )],
                    ),
                  ),
                ),
                Image(image: AssetImage("assets/images/wave.png"))
              ],
            ),
          ),
          Center(
            heightFactor: 2,
            child: LoginForm(),
          )
        ],
      )
    );
  }
}
