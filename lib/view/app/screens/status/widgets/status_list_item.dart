import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/format_time.dart';

class StatusListItem extends StatelessWidget {
  final Status status;
  final String? currentUserId;
  final VoidCallback onTap;

  const StatusListItem({
    super.key,
    required this.status,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unseenCount = currentUserId != null
        ? status.unseenCount(currentUserId!)
        : status.statusItems.length;
    final hasUnseen = unseenCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildAvatar(hasUnseen),
              const SizedBox(width: 16),
              _buildText(),
              if (hasUnseen) _buildBadge(unseenCount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool hasUnseen) {
    return Hero(
      tag: 'profile_${status.userId}',
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasUnseen
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasUnseen ? null : colorScheme.outlineVariant,
        ),
        child: CircleAvatar(
          radius: 27,
          backgroundColor: colorScheme.surfaceContainerHighest,
          backgroundImage: (status.userProfileImage != null &&
                  status.userProfileImage!.isNotEmpty)
              ? NetworkImage(status.userProfileImage!)
              : null,
          child: (status.userProfileImage == null ||
                  status.userProfileImage!.isEmpty)
              ? Icon(Icons.person_rounded,
                  color: colorScheme.onSurfaceVariant, size: 28)
              : null,
        ),
      ),
    );
  }

  Widget _buildText() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.userName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            formatTimeAgo(status.latestItem?.timestamp ?? status.createdAt),
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count new',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
