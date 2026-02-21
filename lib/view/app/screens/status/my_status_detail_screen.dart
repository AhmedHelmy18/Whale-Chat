import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/format_time.dart';
import 'package:whale_chat/view/app/screens/status/view_status_screen.dart';

class MyStatusDetailScreen extends StatelessWidget {
  final Status status;
  final String userImageUrl;

  const MyStatusDetailScreen({
    super.key,
    required this.status,
    required this.userImageUrl,
  });

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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
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
                    backgroundImage: (status.userProfileImage != null &&
                            status.userProfileImage!.isNotEmpty)
                        ? NetworkImage(status.userProfileImage!)
                        : null,
                    child: (status.userProfileImage == null ||
                            status.userProfileImage!.isEmpty)
                        ? Icon(Icons.person, color: colorScheme.surface)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatTimeAgo(status.latestItem?.timestamp ?? DateTime.now()),
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
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: status.statusItems.length,
              itemBuilder: (context, index) {
                final item = status.statusItems[index];
                return _StatusItemTile(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewStatusScreen(
                          status: status,
                          isMyStatus: true,
                          initialIndex: index,
                        ),
                      ),
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
            heroTag: 'edit_status_fab',
            onPressed: () {},
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(Icons.edit, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'camera_status_fab',
            onPressed: () {},
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

  const _StatusItemTile({
    required this.item,
    required this.onTap,
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
              right: 8,
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
