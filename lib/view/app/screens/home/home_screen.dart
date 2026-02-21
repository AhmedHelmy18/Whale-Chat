import 'package:flutter/material.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/search/search_screen.dart';
import 'package:whale_chat/view/app/screens/home/chat_body_widget.dart';
import 'package:whale_chat/view_model/auth_view_model.dart';
import 'package:whale_chat/view_model/home_view_model.dart';
import 'package:whale_chat/theme/color_scheme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeViewModel viewModel = HomeViewModel();
  final AuthViewModel authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    final userId = authViewModel.currentUser?.uid;
    if (userId != null) {
      viewModel.listenToChats(userId);
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 32,
                      color: colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.search_rounded,
                            size: 26,
                            color: colorScheme.surface,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: PopupMenuButton(
                          offset: const Offset(0, 63),
                          color: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 26,
                            color: colorScheme.surface,
                          ),
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await Future.delayed(
                                const Duration(milliseconds: 150),
                              );
                              if (!context.mounted) return;
                              await authViewModel.logout();
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 22,
                                    color: colorScheme.surface,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.surface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              if (viewModel.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 3,
                  ),
                );
              }
              if (viewModel.chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 80,
                            color: colorScheme.grey300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No recent chats",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.grey600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Start a conversation",
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.grey400,
                            ),
                          ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: viewModel.chats.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: colorScheme.grey200,
                  ),
                ),
                itemBuilder: (context, index) {
                  final chat = viewModel.chats[index];
                  return ChatBodyWidget(
                    userId: chat["userId"],
                    userName: chat["name"],
                    lastMessage: chat["lastMessage"],
                    timestamp: chat["timestamp"],
                    conversationId: chat["id"],
                    bio: chat["about"],
                    photoUrl: chat["photoUrl"],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
