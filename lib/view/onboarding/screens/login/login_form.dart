import 'package:flutter/material.dart';
import 'package:whale_chat/app.dart';
import 'package:whale_chat/controller/auth/auth_controller.dart';
import 'package:whale_chat/services/notification_service.dart';
import 'package:whale_chat/util/auth_validator.dart';
import 'package:whale_chat/view/onboarding/components/custom_text_form_field.dart';
import 'package:whale_chat/view/onboarding/components/error_box.dart';
import 'package:whale_chat/view/onboarding/components/primary_button.dart';
import 'package:whale_chat/view/onboarding/screens/forget_password/forget_password_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthController controller = AuthController();
  final NotificationService _notificationService = NotificationService();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? errorText;
  bool submitted = false;

  bool get isFormFilled =>
      emailController.text.trim().isNotEmpty && passwordController.text.trim().isNotEmpty;

  bool get canSubmit => !loading && isFormFilled;

  Future<void> login() async {
    setState(() => submitted = true);

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => loading = true);

    final result = await controller.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (result != null && mounted) {
      if (!await _notificationService.hasPermission()) {
        await _notificationService.requestPermission();
      }
      if (await _notificationService.hasPermission()) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ChatApp()),
              (route) => false,
        );
      } else {
        // Handle the case where the user denies permission
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notification permission is required to use the app."),
          ),
        );
      }
    } else {
      setState(() => errorText = result);
    }

    setState(() => loading = false);
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
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
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
                  MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
                );
              },
              child: const Text("Forgot Password?"),
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            enabled: canSubmit,
            primaryButton: true,
            onPressed: canSubmit ? login : null,
            text: loading ? 'Logging in...' : 'Login',
          ),
        ],
      ),
    );
  }
}
