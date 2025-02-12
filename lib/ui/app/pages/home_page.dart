import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/add_friend.dart';
import 'package:chat_app/ui/app/widgets/chat_user_container.dart';
import 'package:chat_app/ui/app/widgets/search.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: colorScheme.primary,
        title: Text(
          'Chats',
          style: TextStyle(
            fontSize: 30,
            color: colorScheme.surface,
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          right: 20.0,
          left: 20.0,
          bottom: 10,
        ),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ChatUserContainer();
          },
          itemCount: 10,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFriend(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: colorScheme.surface,
        ),
      ),
    );
  }
}
