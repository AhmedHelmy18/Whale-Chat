import 'package:chat_app/auth/pages/sign_up_page.dart';
import 'package:chat_app/theme.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
            onPressed: () {},
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
            onPressed: () {},
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
