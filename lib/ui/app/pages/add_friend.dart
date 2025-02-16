import 'package:chat_app/ui/app/widgets/add_friend_container.dart';

import 'package:flutter/material.dart';

class AddFriend extends StatelessWidget {
  const AddFriend({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (buildContext, index) {
        return AddFriendContainer();
      },
    );
  }
}
