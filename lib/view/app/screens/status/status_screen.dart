import 'package:flutter/material.dart';
import 'package:whale_chat/controller/status/status_controller.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/format_time.dart';
import 'package:whale_chat/view/app/screens/status/add_status_screen.dart';
import 'package:whale_chat/view/app/screens/status/my_status_detail_screen.dart';
import 'package:whale_chat/view/app/screens/status/view_status_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
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
        title: Text(
          'Updates',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Status Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // My Status Card
          SliverToBoxAdapter(
            child: ValueListenableBuilder<Status?>(
              valueListenable: _controller.myStatus,
              builder: (context, myStatus, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: _controller.currentUserImageUrl,
                  builder: (context, imageUrl, _) {
                    return _MyStatusCard(
                      myStatus: myStatus,
                      userImageUrl: imageUrl,
                      onTap: () {
                        if (myStatus != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyStatusDetailScreen(
                                status: myStatus,
                                userImageUrl: imageUrl ?? '',
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
                    );
                  },
                );
              },
            ),
          ),

          // Recent Updates
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Recent updates',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Status List
          ValueListenableBuilder<List<Status>>(
            valueListenable: _controller.statusList,
            builder: (context, statusList, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: _controller.currentUserId,
                builder: (context, currentUserId, _) {
                  if (statusList.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No recent updates',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final status = statusList[index];
                        return _StatusListItem(
                          status: status,
                          currentUserId: currentUserId,
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
                        );
                      },
                      childCount: statusList.length,
                    ),
                  );
                },
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_status_fab',
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
    );
  }
}

class _MyStatusCard extends StatelessWidget {
  final Status? myStatus;
  final String? userImageUrl;
  final VoidCallback onTap;

  const _MyStatusCard({
    required this.myStatus,
    required this.userImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'profile_my_status',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: myStatus != null
                          ? Border.all(color: colorScheme.primary, width: 2.5)
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CircleAvatar(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage:
                            (userImageUrl != null && userImageUrl!.isNotEmpty)
                                ? NetworkImage(userImageUrl!)
                                : null,
                        child: (userImageUrl == null || userImageUrl!.isEmpty)
                            ? Icon(Icons.person,
                                color: colorScheme.onSurfaceVariant)
                            : null,
                      ),
                    ),
                  ),
                ),
                if (myStatus == null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: colorScheme.onPrimary,
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
                    'My status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    myStatus != null
                        ? formatTimeAgo(myStatus!.latestItem?.timestamp ?? myStatus!.createdAt)
                        : 'Tap to add status update',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
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

class _StatusListItem extends StatelessWidget {
  final Status status;
  final String? currentUserId;
  final VoidCallback onTap;

  const _StatusListItem({
    required this.status,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unseenCount =
        currentUserId != null ? status.unseenCount(currentUserId!) : status.statusItems.length;
    final hasUnseen = unseenCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Hero(
              tag: 'profile_${status.userId}',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasUnseen ? colorScheme.primary : colorScheme.outline,
                    width: 2.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: (status.userProfileImage != null && status.userProfileImage!.isNotEmpty)
                        ? NetworkImage(status.userProfileImage!)
                        : null,
                    child: (status.userProfileImage == null || status.userProfileImage!.isEmpty)
                        ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                ),
              ),
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
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatTimeAgo(status.latestItem?.timestamp ?? status.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
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
