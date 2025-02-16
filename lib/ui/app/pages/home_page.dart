import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/add_friend.dart';
import 'package:chat_app/ui/app/widgets/chat_user_container.dart';
import 'package:chat_app/ui/app/widgets/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var chats = [];

  @override
  void initState() {
    super.initState();

    loadChats();
  }

  void loadChats() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((event) async {
      setState(() {
        chats.clear();
      });

      for (var doc in event.data()?["last conversation"]) {
        var conversationRef = await FirebaseFirestore.instance
            .collection('conversations')
            .doc(doc)
            .get();

        if (!conversationRef.exists) continue;

        var participants = conversationRef.data()?["participants"];
        if (participants == null || participants.length < 2) continue;

        var participantData = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid == participants[0]
                ? participants[1]
                : participants[0])
            .get();

        var lastMessageSnapshot = await FirebaseFirestore.instance
            .collection('conversations')
            .doc(doc)
            .collection('messages')
            .orderBy('time', descending: true)
            .limit(1)
            .get();

        String lastMessage = lastMessageSnapshot.docs.isNotEmpty
            ? lastMessageSnapshot.docs.first["text"]
            : "No messages yet";
        Timestamp lastMessageTime = lastMessageSnapshot.docs.isNotEmpty
            ? lastMessageSnapshot.docs.first["time"]
            : Timestamp.now(); // Use current time if no messages

        setState(() {
          chats.add({
            "id": doc,
            "name": participantData.data()?["name"],
            "userId": participantData.id,
            "lastMessage": lastMessage,
            "timestamp": lastMessageTime
          });
        });
      }
    });
  }

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
          if (chats.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return ChatUserContainer(
                userId: chats[index]["userId"],
                userName: chats[index]["name"],
                lastMessage: chats[index]["lastMessage"],
                timestamp: chats[index]["timestamp"],
                conversationId: chats[index]["id"],
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
