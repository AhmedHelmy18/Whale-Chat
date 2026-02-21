import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whale_chat/util/format_time.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/data/model/message.dart';
import 'package:whale_chat/view/app/screens/chat/chat_date.dart';
import 'package:whale_chat/view/app/screens/chat/chat_input_field.dart';
import 'package:whale_chat/view/app/screens/chat/image/image_grid_widget.dart';
import 'package:whale_chat/view/app/screens/chat/image/image_pick_preview.dart';
import 'package:whale_chat/view_model/chat_view_model.dart';

class MessageBodyWidget extends StatefulWidget {
  const MessageBodyWidget({
    super.key,
    required this.conversationId,
    required this.userId,
  });

  final String conversationId;
  final String userId;

  @override
  State<MessageBodyWidget> createState() => _MessageBodyWidgetState();
}

class _MessageBodyWidgetState extends State<MessageBodyWidget> with SingleTickerProviderStateMixin {
  late final ChatViewModel viewModel;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabScaleAnimation;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      // Handle the case where the user is not logged in
      // This might involve popping the screen or redirecting
    }

    viewModel = ChatViewModel(
      conversationId: widget.conversationId,
      currentUserId: currentUserId ?? '',
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Auto scroll to bottom when messages change
    viewModel.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
      if (scrollController.hasClients && viewModel.messages.isNotEmpty) {
           // Small delay to ensure list is rendered
           Future.delayed(const Duration(milliseconds: 100), () {
             if (scrollController.hasClients) {
               scrollController.animateTo(
                 scrollController.position.maxScrollExtent,
                 duration: const Duration(milliseconds: 300),
                 curve: Curves.easeOut,
               );
             }
           });
      }
  }

  @override
  void dispose() {
    viewModel.removeListener(_scrollToBottom);
    viewModel.dispose();
    _fabAnimationController.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Icon _getMessageStatusIcon(String status) {
    if (status == 'sent') {
      return Icon(Icons.check, color: Colors.grey, size: 16);
    } else if (status == 'delivered') {
      return Icon(Icons.done_all, color: Colors.grey, size: 16);
    } else if (status == 'seen') {
      return const Icon(Icons.done_all, color: Colors.blue, size: 16);
    }
    return Icon(Icons.check, color: Colors.grey, size: 16);
  }

  Widget _buildTimeRow(Message message) {
    final textStyle = TextStyle(
      fontSize: 11,
      color: message.isMe ? colorScheme.surface.withValues(alpha: 0.85) : colorScheme.onPrimary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 45),
        Text(formatTime(message.time), style: textStyle),
        if (message.isMe) ...[
          const SizedBox(width: 4),
          _getMessageStatusIcon(message.status),
        ],
      ],
    );
  }

  Widget _imageOverlayIfNeeded(Message message, bool isImageOnly) {
    if (!isImageOnly) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatTime(message.time),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 4),
            const SizedBox.shrink(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message, bool showDateHeader, String formattedDate, double width) {
    final hasImages = message.imageUrls.isNotEmpty;
    final hasText = message.text.isNotEmpty;

    final isImageOnly = hasImages && !hasText;
    final hasBorder = hasImages;

    final maxBubbleWidth = hasImages
        ? (message.imageUrls.length > 1 ? width * 0.75 : width * 0.6)
        : width * 0.85;

    final bubbleInner = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasImages)
          Center(
            child: ImageGridWidget(
              imageUrls: message.imageUrls,
              hasText: hasText,
              containerColor: message.isMe ? colorScheme.primary : colorScheme.secondary,
              borderColor: message.isMe ? colorScheme.primary : colorScheme.secondary,
              overlay: isImageOnly ? _imageOverlayIfNeeded(message, isImageOnly) : null,
            ),
          ),
        if (hasText)
          Padding(
            padding: EdgeInsets.fromLTRB(10, hasImages ? 2 : 4, 10, 2),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? colorScheme.surface : colorScheme.onSurface.withValues(alpha: 0.87),
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        if (hasText && !hasImages)
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildTimeRow(message)],
            ),
          ),
      ],
    );

    Widget bubbleChild;
    if (hasImages && hasText) {
      bubbleChild = Stack(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 12), child: bubbleInner),
          Positioned(right: 10, bottom: 8, child: _buildTimeRow(message)),
        ],
      );
    } else {
      bubbleChild = bubbleInner;
    }

    return Column(
      children: [
        if (showDateHeader) ChatDate(date: formattedDate),
        Align(
          alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(top: 4, bottom: 4, left: message.isMe ? 60 : 8, right: message.isMe ? 8 : 60),
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            decoration: BoxDecoration(
              color: (message.isMe ? colorScheme.primary : colorScheme.secondary),
              borderRadius: BorderRadius.circular(10),
              border: hasBorder ? Border.all(color: message.isMe ? colorScheme.primary : colorScheme.secondary, width: 3) : null,
            ),
            child: bubbleChild,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (_, __) {
              final safeMessages = viewModel.messages;

              return ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: safeMessages.length,
                itemBuilder: (context, index) {
                  final message = safeMessages[index];
                  final formattedRawDate = formatDate(message.time);
                  final showDateHeader = index == 0 || formatDate(safeMessages[index - 1].time) != formattedRawDate;
                  final formattedDate = formatChatDateHeader(message.time);

                  return _buildMessageItem(message, showDateHeader, formattedDate, width);
                },
              );
            },
          ),
        ),
        ImagePickPreview(viewModel: viewModel),
        ChatInputField(
          viewModel: viewModel,
          messageController: messageController,
          fabAnimationController: _fabAnimationController,
          fabScaleAnimation: _fabScaleAnimation,
        ),
      ],
    );
  }
}
