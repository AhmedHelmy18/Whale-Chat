import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/format_time.dart';

class StatusItemTile extends StatelessWidget {
  final StatusItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const StatusItemTile({
    super.key,
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
          borderRadius: BorderRadius.circular(16),
          color: _backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildContent(),
            if (item.type == StatusType.image) _buildBottomGradient(),
            _buildTimestampChip(),
            _buildMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (item.type == StatusType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          item.content,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(Icons.broken_image_rounded,
                  color: colorScheme.onSurfaceVariant, size: 32),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _backgroundColor,
              _backgroundColor.withValues(alpha: 0.75)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              item.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGradient() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestampChip() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          formatTimeAgo(item.timestamp),
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return Positioned(
      top: 2,
      right: 2,
      child: PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.more_vert_rounded,
              size: 16, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_rounded, color: colorScheme.error, size: 18),
                const SizedBox(width: 10),
                Text('Delete', style: TextStyle(color: colorScheme.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    if (item.type == StatusType.text && item.backgroundColor != null) {
      try {
        String hex = item.backgroundColor!.replaceAll('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      } catch (_) {
        return colorScheme.primary;
      }
    }
    return colorScheme.surfaceContainerHighest;
  }
}
