import 'package:flutter/material.dart';
import 'package:whale_chat/view_model/status_view_model.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/util/format_time.dart';
import 'package:whale_chat/view/app/screens/status/add_status_screen.dart';
import 'package:whale_chat/view/app/screens/status/view_status_screen.dart';
import 'package:whale_chat/view/app/screens/status/widgets/status_item_tile.dart';

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
      appBar: _buildAppBar(),
      floatingActionButton: _buildFab(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildEncryptionBanner(),
          _buildSectionLabel(),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              const Text(
                'My status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Hero(
            tag: 'profile_my_status',
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: (widget.status.userProfileImage != null &&
                        widget.status.userProfileImage!.isNotEmpty)
                    ? NetworkImage(widget.status.userProfileImage!)
                    : null,
                child: (widget.status.userProfileImage == null ||
                        widget.status.userProfileImage!.isEmpty)
                    ? Icon(Icons.person_rounded,
                        color: colorScheme.onSurfaceVariant, size: 28)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.status.userName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.status.latestItem != null
                    ? formatTimeAgo(widget.status.latestItem!.timestamp)
                    : formatTimeAgo(widget.status.createdAt),
                style: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded,
              size: 16, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: colorScheme.onPrimaryContainer,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(text: 'Your status updates are '),
                  TextSpan(
                    text: 'end-to-end encrypted',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: '. They disappear after 24 hours.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        'YOUR UPDATES',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final displayStatus = _viewModel.myStatus ?? widget.status;

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
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: displayStatus.statusItems.length,
          itemBuilder: (context, index) {
            final item = displayStatus.statusItems[index];
            return StatusItemTile(
              item: item,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewStatusScreen(
                    status: displayStatus,
                    isMyStatus: true,
                    initialIndex: index,
                  ),
                ),
              ),
              onDelete: () => _confirmDelete(context, displayStatus, item),
            );
          },
        );
      },
    );
  }

  Widget _buildFab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'text_status_fab',
          elevation: 4,
          backgroundColor: colorScheme.surfaceContainerHighest,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddStatusScreen(isTextMode: true),
            ),
          ),
          child: Icon(Icons.edit_rounded, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'camera_status_fab',
          elevation: 6,
          backgroundColor: colorScheme.primary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStatusScreen()),
          ),
          child: Icon(Icons.camera_alt_rounded, color: colorScheme.surface),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Status displayStatus, StatusItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _viewModel.deleteStatusItem(displayStatus.id, item.id);
    }
  }
}
