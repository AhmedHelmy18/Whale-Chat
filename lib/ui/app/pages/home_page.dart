import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/add_friend.dart';
import 'package:chat_app/ui/app/widgets/chat_user_container.dart';
import 'package:chat_app/ui/app/widgets/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: currentUserId)
            .orderBy('timestamp',
                descending: true) // Order by last message time
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No recent chats",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }

          var chatUsers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: chatUsers.length,
            itemBuilder: (context, index) {
              var chat = chatUsers[index].data() as Map<String, dynamic>;
              List participants = chat['participants'];
              String otherUserId =
                  participants.firstWhere((id) => id != currentUserId);
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return SizedBox(); // Don't show anything until data is ready
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return ChatUserContainer(
                    userId: otherUserId,
                    userName: userData['name'] ?? 'Unknown',
                    lastMessage: chat['lastMessage'] ?? '',
                    timestamp: chat['timestamp'],
                    conversationId: chatUsers[index].id,
                  );
                },
              );
            },
          );
        },
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
