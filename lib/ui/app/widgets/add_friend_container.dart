import 'package:chat_app/constants/theme.dart';
import 'package:flutter/material.dart';

class AddFriendContainer extends StatelessWidget {
  const AddFriendContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 5,
        left: 8,
        right: 8,
      ),
      height: 80,
      decoration: BoxDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/download.jpeg',
            height: 60,
          ),
          Spacer(
            flex: 2,
          ),
          Text(
            'User Name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(
            flex: 4,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Add Friend',
              style: TextStyle(
                color: colorScheme.surface,
                fontSize: 15,
              ),
            ),
          ),
          Spacer(),
          IconButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            icon: Icon(
              Icons.delete,
              color: colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
