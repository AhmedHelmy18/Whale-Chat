import 'package:flutter/material.dart';
import 'package:whale_chat/theme/color_scheme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    required this.primaryButton,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool enabled;
  final bool primaryButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? (primaryButton ? colorScheme.primary : colorScheme.surface)
              : colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: primaryButton
                ? BorderSide.none
                : BorderSide(color: colorScheme.primary),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(
          text,
          style: TextStyle(
            color: enabled
                ? (primaryButton ? colorScheme.surface : colorScheme.primary)
                : colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
