import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/format_time.dart';

class MyStatusCard extends StatelessWidget {
  final Status? myStatus;
  final String? userImageUrl;
  final VoidCallback onTap;

  const MyStatusCard({
    super.key,
    required this.myStatus,
    required this.userImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveStatus = myStatus != null && myStatus!.isValid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              _buildAvatar(hasActiveStatus),
              const SizedBox(width: 16),
              _buildText(hasActiveStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool hasActiveStatus) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasActiveStatus
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: hasActiveStatus ? null : colorScheme.outlineVariant,
          ),
          child: Hero(
            tag: 'profile_my_status',
            child: CircleAvatar(
              radius: 27,
              backgroundColor: colorScheme.surfaceContainerHighest,
              backgroundImage:
                  (userImageUrl != null && userImageUrl!.isNotEmpty)
                      ? NetworkImage(userImageUrl!)
                      : null,
              child: (userImageUrl == null || userImageUrl!.isEmpty)
                  ? Icon(Icons.person_rounded,
                      color: colorScheme.onSurfaceVariant, size: 28)
                  : null,
            ),
          ),
        ),
        if (!hasActiveStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: Icon(Icons.add_rounded,
                  size: 12, color: colorScheme.onPrimary),
            ),
          ),
      ],
    );
  }

  Widget _buildText(bool hasActiveStatus) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hasActiveStatus
                ? formatTimeAgo(
                    myStatus!.latestItem?.timestamp ?? myStatus!.createdAt)
                : 'Tap to add status update',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
