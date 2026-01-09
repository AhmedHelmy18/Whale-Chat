import 'package:flutter/material.dart';
import 'package:whale_chat/app.dart';
import 'package:whale_chat/controller/auth_controller.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/auth_validator.dart';
import 'package:whale_chat/view/onboarding/pages/forget_password.dart';
import 'package:whale_chat/view/onboarding/pages/sign_up_page.dart';
import 'package:whale_chat/view/onboarding/widgets/custom_text_form_field.dart';
import 'package:whale_chat/view/onboarding/widgets/error_box.dart';
import 'package:whale_chat/view/onboarding/widgets/primary_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthController controller = AuthController();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? errorText;
  bool submitted = false;

  void login() async {
    setState(() => submitted = true);
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await controller.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    if (!mounted) return;
    if (result == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ChatApp()),
            (route) => false,
      );
    } else {
      setState(() => errorText = result);
    }
    setState(() => loading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (final controller in [emailController, passwordController]) {
      controller.addListener(() {
        if (submitted) {
          formKey.currentState?.validate();
        }
        if (errorText != null) {
          setState(() => errorText = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        children: [
          if (errorText != null) ErrorBox(content: errorText!),
          CustomTextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            hintText: 'John@gmail.com',
            icon: Icons.email,
            validator: AuthValidator.emailValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            keyboardType: TextInputType.text,
            controller: passwordController,
            isPasswordField: true,
            icon: Icons.lock,
            hintText: '********',
            textInputAction: TextInputAction.done,
            validator: AuthValidator.passwordValidator,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgetPassword()),
                );
              },
              child: const Text("Forgot Password?"),
            ),
          ),
          PrimaryButton(
            enabled: !loading,
            primaryButton: true,
            onPressed: login,
            text: loading ? 'Logging in...' : 'Login',
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Divider(
                  color: colorScheme.secondary,
                  thickness: 2,
                  endIndent: 10,
                ),
              ),
              Text('or', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Expanded(
                child: Divider(
                  color: colorScheme.secondary,
                  thickness: 2,
                  indent: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          PrimaryButton(
            primaryButton: false,
            text: 'Sign up',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
