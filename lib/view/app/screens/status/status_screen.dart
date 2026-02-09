import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whale_chat/controller/status/status_controller.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/status/add_status_screen.dart';
import 'package:whale_chat/view/app/screens/status/view_status_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final StatusController _controller = StatusController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusAppBar(),
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: StreamBuilder<Status?>(
                      stream: _controller.getMyStatus(),
                      builder: (context, snapshot) {
                        final myStatus = snapshot.data;
                        final currentUser = FirebaseAuth.instance.currentUser;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: _MyStatusCard(
                            myStatus: myStatus,
                            currentUser: currentUser,
                            onTap: () {
                              if (myStatus != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewStatusScreen(
                                      status: myStatus,
                                      isMyStatus: true,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddStatusScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
                      child: Text(
                        'Recent Updates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),

                  StreamBuilder<List<Status>>(
                    stream: _controller.getStatuses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.radio_button_checked,
                                    size: 64,
                                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No recent updates',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final statuses = snapshot.data!;
                      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final status = statuses[index];
                            final unseenCount = status.unseenCount(currentUserId);
                            final hasUnseen = unseenCount > 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: _StatusListItem(
                                status: status,
                                hasUnseen: hasUnseen,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewStatusScreen(
                                        status: status,
                                        isMyStatus: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: statuses.length,
                        ),
                      );
                    },
                  ),
                ],
              ),

              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddStatusScreen()),
                    );
                  },
                  backgroundColor: colorScheme.primary,
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    color: colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _StatusAppBar();

  static const double _height = 100.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: _height,
        child: Stack(
          children: [
            const _StatusBackground(),
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 16),
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 28,
                      color: colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBackground extends StatelessWidget {
  const _StatusBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyStatusCard extends StatelessWidget {
  const _MyStatusCard({
    required this.myStatus,
    required this.currentUser,
    required this.onTap,
  });

  final Status? myStatus;
  final User? currentUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = myStatus?.latestItem;
    final subtitle = latest != null ? _getTimeAgoStatic(latest.timestamp) : 'Tap to add status update';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: myStatus != null
                            ? Border.all(
                                color: colorScheme.primary,
                                width: 2.5,
                              )
                            : null,
                      ),
                      child: ClipOval(
                        child: currentUser?.photoURL != null
                            ? Image.network(
                                currentUser!.photoURL!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/download.jpeg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if (myStatus == null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 12,
                            color: colorScheme.surface,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myStatus != null ? 'My Status' : 'Add Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusListItem extends StatelessWidget {
  const _StatusListItem({
    required this.status,
    required this.hasUnseen,
    required this.onTap,
  });

  final Status status;
  final bool hasUnseen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnseen ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3),
                      width: hasUnseen ? 2.5 : 2,
                    ),
                  ),
                  child: ClipOval(
                    child: status.userProfileImage != null
                        ? Image.network(status.userProfileImage!, fit: BoxFit.cover)
                        : Image.asset('assets/images/download.jpeg', fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
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
                  const SizedBox(height: 2),
                  Text(
                    _getTimeAgoStatic(status.latestItem!.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getTimeAgoStatic(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return 'Yesterday';
  }
}