import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whale_chat/app.dart';
import 'package:whale_chat/data/service/notification_service.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/common/custom_snackbar.dart';
import 'package:whale_chat/view/onboarding/components/primary_button.dart';

class EmailVerifyScreen extends StatefulWidget {
  final String email;
  final String name;

  const EmailVerifyScreen({super.key, required this.email, required this.name});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> with SingleTickerProviderStateMixin {
  bool loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> checkVerification() async {
    setState(() => loading = true);

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.email == widget.email) {
        if (user.emailVerified) {
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
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ChatApp()),
                  (route) => false,
            );
          }
        } else {
          if (!mounted) return;
          showCustomSnackBar(context, "Email not verified yet. Please check your inbox.", isError: true);
        }
      } else {
        if (!mounted) return;
        showCustomSnackBar(context, "This email does not match your account.", isError: true);
      }
    } else {
      if (!mounted) return;
      showCustomSnackBar(context, "No signed-in user found.", isError: true);
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "We've sent a verification link to:",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            widget.email,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Expanded(
                    child: Center(
                      child: Image.asset(
                        "assets/images/emailVerify.png",
                        height: 280,
                        width: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Check your inbox and click the verification link to continue",
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: loading ? 'Checking...' : 'I\'ve Verified My Email',
                      onPressed: checkVerification,
                      primaryButton: true,
                      enabled: !loading,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: loading ? null : () {
                      showCustomSnackBar(context, "Verification email sent!");
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: loading ? colorScheme.outline : colorScheme.primary,
                    ),
                    label: Text(
                      "Didn't receive the email? Resend",
                      style: TextStyle(
                        color: loading ? colorScheme.outline : colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
