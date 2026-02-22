import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/common/image_options/source_option.dart';

Future<void> showImageSourcePicker(
    {required BuildContext context,
    required Future<void> Function(ImageSource source) onPick}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Text(
                'Choose Photo Source',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 24),
              SourceOption(
                icon: Icons.photo_library_rounded,
                title: 'Gallery',
                subtitle: 'Choose photo',
                onTap: () async {
                  Navigator.pop(context);
                  await onPick(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              SourceOption(
                icon: Icons.camera_alt_rounded,
                title: 'Camera',
                subtitle: 'Take a new photo',
                onTap: () async {
                  Navigator.pop(context);
                  await onPick(ImageSource.camera);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}
