import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/view_model/status_view_model.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/status/add_status_screen.dart';
import 'package:whale_chat/view/app/screens/status/my_status_detail_screen.dart';
import 'package:whale_chat/view/app/screens/status/view_status_screen.dart';
import 'package:whale_chat/view/app/screens/status/widgets/my_status_card.dart';
import 'package:whale_chat/view/app/screens/status/widgets/status_empty_state.dart';
import 'package:whale_chat/view/app/screens/status/widgets/status_fab.dart';
import 'package:whale_chat/view/app/screens/status/widgets/status_header.dart';
import 'package:whale_chat/view/app/screens/status/widgets/status_list_item.dart';

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
    return Stack(
      children: [
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final myStatus = _viewModel.myStatus;
            final userImageUrl = _viewModel.currentUserImageUrl;
            final statusList = _viewModel.statuses;
            final currentUserId = _viewModel.currentUserId;

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: StatusHeader()),
                SliverToBoxAdapter(
                  child: MyStatusCard(
                    myStatus: myStatus,
                    userImageUrl: userImageUrl,
                    onTap: () =>
                        _onMyStatusTap(context, myStatus, userImageUrl),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Divider(
                      height: 1,
                      thickness: 0.5,
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'RECENT UPDATES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                if (statusList.isEmpty)
                  const SliverToBoxAdapter(child: StatusEmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final status = statusList[index];
                        return StatusListItem(
                          status: status,
                          currentUserId: currentUserId,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewStatusScreen(
                                status: status,
                                isMyStatus: false,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: statusList.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
        const Positioned(
          bottom: 16,
          right: 16,
          child: StatusFab(),
        ),
      ],
    );
  }

  void _onMyStatusTap(
      BuildContext context, Status? myStatus, String? userImageUrl) {
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
        MaterialPageRoute(builder: (_) => const AddStatusScreen()),
      );
    }
  }
}
