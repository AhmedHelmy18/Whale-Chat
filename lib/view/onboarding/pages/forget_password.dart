import 'package:flutter/material.dart';
import 'package:whale_chat/util/auth_validator.dart';
import 'package:whale_chat/view/onboarding/widgets/custom_text_form_field.dart';
import 'package:whale_chat/view/onboarding/widgets/error_box.dart';
import 'package:whale_chat/view/onboarding/widgets/primary_button.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/onboarding/pages/verify_email.dart';
import 'package:whale_chat/controller/auth_controller.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController controller = AuthController();

  bool submitted = false;
  bool loading = false;
  String? errorText;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      if (submitted) formKey.currentState?.validate();
      if (errorText != null) setState(() => errorText = null);
    });
  }

  Future<void> resetPassword() async {
    setState(() => submitted = true);

    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      errorText = null;
    });

    final error = await controller.forgetPassword(
      email: emailController.text.trim(),
    );

    setState(() => loading = false);

    if (error != null) {
      setState(() => errorText = error);
      return;
    }

    if (!mounted) return;
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => VerifyEmailPage(
    //       email: emailController.text.trim(),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Forget Password',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enter your email address to reset your password.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                hintText: "John@email.com",
                validator: AuthValidator.emailValidator,
                controller: emailController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email,
              ),
              const SizedBox(height: 15),
              PrimaryButton(
                text: loading ? "Loading..." : "Reset Password",
                primaryButton: true,
                onPressed: loading ? null : resetPassword,
                enabled: !loading,
              ),
              const SizedBox(height: 15),
              if (errorText != null) ErrorBox(content: errorText!),
            ],
          ),
        ),
      ),
    );
  }
}
