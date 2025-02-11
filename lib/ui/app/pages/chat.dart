import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/widgets/message_body.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: colorScheme.primary,
        leading: SizedBox(
          width: 60, // Define a width for leading
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.surface,
            ),
          ),
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/download.jpeg',
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'User Name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ],
        ),
      ),
      body: MessageBody(),
    );
  }
}
