import 'package:chat_app/cubits/auth_cubit/auth_cubit.dart';
import 'package:chat_app/ui/onboarding/pages/login_page.dart';
import 'package:chat_app/ui/onboarding/common/error_box.dart';
import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignupForm extends StatelessWidget {
  SignupForm({super.key});

  String? email, password, name;
  final GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is SignUpLoading) {
          isLoading = true;
        }
        if (state is SignUpSuccess) {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              (route) => false,
            );
          }
        }
        if (state is SignUpFailure) {
          ErrorBox(content: state.errMessage);
        }
      },
      builder: (context, state) {
        return Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (state is SignUpFailure)
                  ? ErrorBox(content: state.errMessage)
                  : Container(),
              TextFormField(
                onChanged: (data) {
                  name = data;
                },
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter your name' : null,
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
              TextFormField(
                onChanged: (data) {
                  email = data;
                },
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter your email'
                    : null,
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
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  bool obscureText = context.watch<AuthCubit>().obscureText;
                  return TextFormField(
                    onChanged: (data) {
                      password = data;
                    },
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password'
                        : null,
                    textInputAction: TextInputAction.done,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          BlocProvider.of<AuthCubit>(context)
                              .toggleObscureText();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Password',
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ModalProgressHUD(
                inAsyncCall: state is SignUpLoading,
                child: SizedBox(
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
                        BlocProvider.of<AuthCubit>(context).signUp(
                          email: email ?? '',
                          password: password ?? '',
                          name: name ?? '',
                        );
                      }
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: colorScheme.onPrimary),
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
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: Text('Log in'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
