import 'package:flutter/material.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/common/image_options/model_sheet_options.dart';
import 'package:whale_chat/view_model/chat_view_model.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({
    super.key,
    required this.viewModel,
    required this.messageController,
    required this.fabAnimationController,
    required this.fabScaleAnimation,
  });

  final ChatViewModel viewModel;
  final TextEditingController messageController;
  final AnimationController fabAnimationController;
  final Animation<double> fabScaleAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.attach_file_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          showImageSourcePicker(
                            context: context,
                            onPick: (source) async {
                              await viewModel.pickSingleImage(source);
                            },
                          );
                        },

                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTapDown: (_) => fabAnimationController.forward(),
              onTapUp: (_) => fabAnimationController.reverse(),
              onTapCancel: () => fabAnimationController.reverse(),
              onTap: () async {
                final text = messageController.text;
                if (text.trim().isEmpty && viewModel.pickedImages.isEmpty) return;
                await viewModel.sendMessage(text);
                messageController.clear();
              },
              child: ScaleTransition(
                scale: fabScaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.send_rounded, color: colorScheme.surface, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
