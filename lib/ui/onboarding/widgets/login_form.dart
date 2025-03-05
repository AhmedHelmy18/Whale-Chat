import 'package:chat_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:chat_app/ui/onboarding/pages/forget_password.dart';
import 'package:chat_app/ui/onboarding/pages/sign_up_page.dart';
import 'package:chat_app/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    String? email, password;
    bool obscureText = BlocProvider.of<AuthCubit>(context).obscureText;
    final GlobalKey<FormState> formKey = GlobalKey();
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            onChanged: (data) {
              email = data;
            },
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter your email' : null,
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
          TextFormField(
            onChanged: (data) {
              password = data;
            },
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter your password' : null,
            textInputAction: TextInputAction.done,
            obscureText: obscureText,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  BlocProvider.of<AuthCubit>(context).toggleObscureText();
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
                if (formKey.currentState!.validate()) {
                  BlocProvider.of<AuthCubit>(context).login(
                    email: email ?? '',
                    password: password ?? '',
                  );
                }
              },
              child: Text(
                'Log in',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
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
      ),
    );
  }
}
