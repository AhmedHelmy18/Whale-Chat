import 'package:whale_chat/controller/home_controller.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/widgets/chat_user_container.dart';
import 'package:whale_chat/view/app/pages/search.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = HomeController();

  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller.listenToChats(
      onChatsUpdated: (updatedChats) {
        if (!mounted) return;
        setState(() => chats = updatedChats);
      },
      onLoadingChanged: (loading) {
        if (!mounted) return;
        setState(() => isLoading = loading);
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: colorScheme.primary,
          title: Text(
            'Chat',
            style: TextStyle(
              fontSize: 30,
              color: colorScheme.surface,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Search(),
                  ),
                );
              },
              icon: Icon(
                Icons.search_outlined,
                size: 30,
                color: colorScheme.surface,
              ),
            ),
            PopupMenuButton(
              offset: const Offset(0, 58),
              elevation: 10,
              color: colorScheme.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              icon: Icon(
                Icons.more_vert,
                size: 30,
                color: colorScheme.surface,
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  controller.logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: 25,
                        color: colorScheme.surface,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : chats.isEmpty
                  ? const Center(
                      child: Text(
                        "No recent chats",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return ChatUserContainer(
                          userId: chat["userId"],
                          userName: chat["name"],
                          lastMessage: chat["lastMessage"],
                          timestamp: chat["timestamp"],
                          conversationId: chat["id"],
                          bio: chat["bio"],
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
