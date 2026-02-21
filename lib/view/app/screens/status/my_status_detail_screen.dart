import 'package:flutter/material.dart';
import 'package:whale_chat/controller/status/status_controller.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/format_time.dart';
import 'package:whale_chat/view/app/screens/status/add_status_screen.dart';
import 'package:whale_chat/view/app/screens/status/view_status_screen.dart';

class MyStatusDetailScreen extends StatefulWidget {
  final Status status;
  final String userImageUrl;

  const MyStatusDetailScreen({
    super.key,
    required this.status,
    required this.userImageUrl,
  });

  @override
  State<MyStatusDetailScreen> createState() => _MyStatusDetailScreenState();
}

class _MyStatusDetailScreenState extends State<MyStatusDetailScreen> {
  final StatusController _controller = StatusController();

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My status',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: 'profile_my_status',
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: colorScheme.outline,
                    backgroundImage: (widget.status.userProfileImage != null &&
                            widget.status.userProfileImage!.isNotEmpty)
                        ? NetworkImage(widget.status.userProfileImage!)
                        : null,
                    child: (widget.status.userProfileImage == null ||
                            widget.status.userProfileImage!.isEmpty)
                        ? Icon(Icons.person, color: colorScheme.surface)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.status.latestItem != null
                      ? formatTimeAgo(widget.status.latestItem!.timestamp)
                      : formatTimeAgo(widget.status.createdAt),
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Encryption Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      children: [
                        const TextSpan(text: 'Your status updates are '),
                        TextSpan(
                          text: 'end-to-end encrypted',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        const TextSpan(
                            text: '. They will disappear after 24 hours.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status Items Grid
          Expanded(
            child: ValueListenableBuilder<Status?>(
              valueListenable: _controller.myStatus,
              builder: (context, myStatus, _) {
                final displayStatus = myStatus ?? widget.status;

                if (displayStatus.statusItems.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) Navigator.pop(context);
                  });
                  return const SizedBox.shrink();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: displayStatus.statusItems.length,
                  itemBuilder: (context, index) {
                    final item = displayStatus.statusItems[index];
                    return _StatusItemTile(
                      item: item,
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete status update?'),
                            content: const Text(
                                'This status update will be deleted for everyone who received it.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _controller.deleteStatusItem(
                              displayStatus.id, item.id);
                        }
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewStatusScreen(
                              status: displayStatus,
                              isMyStatus: true,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'text_status_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddStatusScreen(isTextMode: true),
                ),
              );
            },
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(Icons.edit, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'camera_status_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddStatusScreen(),
                ),
              );
            },
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.camera_alt, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _StatusItemTile extends StatelessWidget {
  final StatusItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StatusItemTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _getBackgroundColor(),
        ),
        child: Stack(
          children: [
            // Background Image or Color
            if (item.type == StatusType.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.content,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    item.content,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Time Indicator
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.scrim.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formatTimeAgo(item.timestamp),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Delete Button
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.scrim.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (item.type == StatusType.text && item.backgroundColor != null) {
      try {
        String hex = item.backgroundColor!.replaceAll('#', '');
        if (hex.length == 6) {
          hex = 'FF$hex';
        }
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        return colorScheme.primary;
      }
    }
    return colorScheme.surfaceContainerHighest;
  }
}
