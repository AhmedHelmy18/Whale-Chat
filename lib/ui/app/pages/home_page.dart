import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/widgets/bottom_nav_bar.dart';
import 'package:chat_app/ui/app/widgets/chat_user_container.dart';
import 'package:chat_app/ui/app/pages/search.dart';

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
  bool isLoading = true;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Set<String> processedUserIds = {};

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    _loadChats();
  }

  void _loadChats() async {
    setState(() => isLoading = true);
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .listen(
      (event) async {
        for (var doc in event.data()?["last conversation"]) {
          var conversationRef =
              await fireStore.collection('conversations').doc(doc).get();

          if (!conversationRef.exists) continue;

          var participants = conversationRef.data()?["participants"];
          if (participants == null || participants.length < 2) continue;

          String otherUserId = currentUserId == participants[0]
              ? participants[1]
              : participants[0];

          String conversationKey = currentUserId.compareTo(otherUserId) < 0
              ? "$currentUserId-$otherUserId"
              : "$otherUserId-$currentUserId";

          if (processedUserIds.contains(conversationKey)) {
            continue;
          }

          processedUserIds.add(conversationKey);

          var participantData =
              await fireStore.collection('users').doc(otherUserId).get();

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
              : Timestamp.now();

          if (!mounted) return;
          setState(() {
            chats.add({
              "id": doc,
              "name": participantData.data()?["name"],
              "userId": participantData.id,
              "lastMessage": lastMessage,
              "timestamp": lastMessageTime,
              "bio": participantData.data()?["bio"]
            });
          });
        }
      },
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
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
            offset: const Offset(0, 70),
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
                FirebaseAuth.instance.signOut();
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
                    SizedBox(
                      width: 10,
                    ),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('participants', arrayContains: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
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
                bio: chats[index]["bio"],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavbar(),
    );
  }
}
