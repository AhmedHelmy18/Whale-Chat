import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/widgets/add_friend_container.dart';
import 'package:chat_app/ui/app/widgets/search.dart';
import 'package:flutter/material.dart';

class AddFriend extends StatelessWidget {
  const AddFriend({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Search Person',
          style: TextStyle(
              fontSize: 20,
              color: colorScheme.surface,
              fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.surface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Search(),
                ),
              );
            },
            icon: Icon(
              Icons.search_outlined,
              color: colorScheme.surface,
              size: 30,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (buildContext, index) {
          return AddFriendContainer();
        },
      ),
    );
  }
}
