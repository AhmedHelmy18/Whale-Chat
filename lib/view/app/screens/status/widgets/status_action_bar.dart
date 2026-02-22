import 'package:flutter/material.dart';
import 'package:whale_chat/theme/color_scheme.dart';

class StatusActionBar extends StatelessWidget {
  final bool isImageMode;
  final TextEditingController captionController;
  final bool isLoading;
  final VoidCallback onPickImage;
  final VoidCallback onPost;

  const StatusActionBar({
    super.key,
    required this.isImageMode,
    required this.captionController,
    required this.isLoading,
    required this.onPickImage,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isImageMode ? _buildCaptionField() : _buildPickerButton(),
            const SizedBox(width: 12),
            _buildPostButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: TextField(
          controller: captionController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Add a caption...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton() {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: const Icon(Icons.image_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildPostButton() {
    return GestureDetector(
      onTap: isLoading ? null : onPost,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14.0),
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : const Icon(Icons.send_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
