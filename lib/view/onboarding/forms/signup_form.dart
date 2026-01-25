import 'package:whale_chat/controller/auth/auth_controller.dart';
import 'package:whale_chat/util/auth_validator.dart';
import 'package:whale_chat/view/onboarding/pages/login_page.dart';
import 'package:whale_chat/view/onboarding/pages/verify_email.dart';
import 'package:whale_chat/view/onboarding/widgets/custom_text_form_field.dart';
import 'package:whale_chat/view/onboarding/widgets/error_box.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:whale_chat/view/onboarding/widgets/primary_button.dart';

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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController controller = AuthController();
  bool loading = false;
  String? errorText;
  bool submitted = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (final controller in [
      emailController,
      passwordController,
      nameController
    ]) {
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

  Future<void> signUp() async {
    setState(() => loading = true);

    final result = await controller.signUp(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
    );

    if (result != null) {
      setState(() {
        errorText = result;
        loading = false;
      });
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyEmailPage(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
        ),
      ),
    );

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (errorText != null) ErrorBox(content: errorText!),
          CustomTextFormField(
            controller: nameController,
            keyboardType: TextInputType.name,
            hintText: 'John Wick',
            icon: Icons.person,
            validator: AuthValidator.nameValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 15),
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
          const SizedBox(height: 15),
          PrimaryButton(
              enabled: !loading,
              primaryButton: true,
              text: loading ? 'Loading...' : 'Sign Up',
              onPressed: signUp),
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
              Text('or',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
            text: 'Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
