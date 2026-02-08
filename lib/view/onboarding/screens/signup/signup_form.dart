import 'package:flutter/material.dart';
import 'package:whale_chat/controller/auth/auth_controller.dart';
import 'package:whale_chat/util/auth_validator.dart';
import 'package:whale_chat/view/onboarding/components/custom_text_form_field.dart';
import 'package:whale_chat/view/onboarding/components/error_box.dart';
import 'package:whale_chat/view/onboarding/components/primary_button.dart';
import 'package:whale_chat/view/onboarding/screens/email_verify/email_verify_screen.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool obscureText = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController controller = AuthController();

  bool loading = false;
  String? errorText;
  bool submitted = false;

  bool get isFormFilled =>
      nameController.text.trim().isNotEmpty && emailController.text.trim().isNotEmpty && passwordController.text.trim().isNotEmpty;

  bool get canSubmit => !loading && isFormFilled;

  @override
  void initState() {
    super.initState();

    for (final controller in [nameController, emailController, passwordController]) {
      controller.addListener(() {
        if (submitted) {
          formKey.currentState?.validate();
        }

        if (errorText != null) {
          setState(() => errorText = null);
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    setState(() {
      submitted = true;
    });

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

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
    setState(() => loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EmailVerifyScreen(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
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
          const SizedBox(height: 25),
          PrimaryButton(
            enabled: canSubmit,
            primaryButton: true,
            text: loading ? 'Loading...' : 'Sign Up',
            onPressed: canSubmit ? signUp : null,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
