import 'package:flutter/material.dart';
import 'package:whale_chat/view_model/status_view_model.dart';
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
  final StatusViewModel _viewModel = StatusViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: const _FloatingStatusButtons(),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final myStatus = _viewModel.myStatus;
          final userImageUrl = _viewModel.currentUserImageUrl;
          final statusList = _viewModel.statuses;
          final currentUserId = _viewModel.currentUserId;

          return CustomScrollView(
            slivers: [
              // My Status Card
              SliverToBoxAdapter(
                child: _MyStatusCard(
                    myStatus: myStatus,
                    userImageUrl: userImageUrl,
                    onTap: () {
                      if (myStatus != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyStatusDetailScreen(
                              status: myStatus,
                              userImageUrl: userImageUrl ?? '',
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
                ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 32),
                  ),
                ),

                // Recent Updates Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Recent updates',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                // Status List
                if (statusList.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
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
                  )
                else
                  SliverList(
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
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
      );
  }
}

class _FloatingStatusButtons extends StatelessWidget {
  const _FloatingStatusButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
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
            child: Icon(Icons.edit, color: colorScheme.onSurfaceVariant),
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          Hero(
            tag: 'profile_my_status',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: myStatus != null && myStatus!.isValid
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage:
                    (userImageUrl != null && userImageUrl!.isNotEmpty)
                        ? NetworkImage(userImageUrl!)
                        : null,
                child: (userImageUrl == null || userImageUrl!.isEmpty)
                    ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                    : null,
              ),
            ),
          ),
          if (myStatus == null || !myStatus!.isValid)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
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
      title: Text(
        'My status',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          myStatus != null && myStatus!.isValid
              ? formatTimeAgo(myStatus!.latestItem?.timestamp ?? myStatus!.createdAt)
              : 'Tap to add status update',
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurfaceVariant,
          ),
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

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Hero(
        tag: 'profile_${status.userId}',
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: hasUnseen ? colorScheme.primary : colorScheme.outline,
              width: 2.5,
            ),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: colorScheme.surfaceContainerHighest,
            backgroundImage:
                (status.userProfileImage != null && status.userProfileImage!.isNotEmpty)
                    ? NetworkImage(status.userProfileImage!)
                    : null,
            child: (status.userProfileImage == null || status.userProfileImage!.isEmpty)
                ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                : null,
          ),
        ),
      ),
      title: Text(
        status.userName,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          formatTimeAgo(status.latestItem?.timestamp ?? status.createdAt),
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
