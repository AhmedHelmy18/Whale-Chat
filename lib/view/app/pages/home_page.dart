import 'dart:async';
import 'package:chat_app/theme/color_scheme.dart';
import 'package:chat_app/view/app/widgets/chat_user_container.dart';
import 'package:chat_app/view/app/pages/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  StreamSubscription? chatSubscription;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  void loadChats() {
    chatSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .listen((event) async {
      if (!mounted) return;

      var lastConversations = event.data()?["last conversation"];
      if (lastConversations == null || lastConversations.isEmpty) {
        setState(() {
          isLoading = false;
          chats = [];
        });
        return;
      }

      // List<dynamic> conversationList = lastConversations is List
      //     ? lastConversations
      //     : lastConversations.values.toList();

      List<Map<String, dynamic>> newChats = [];

      for (var doc in lastConversations) {
        if (doc == null || doc.isEmpty) continue;

        var conversationRef =
            await fireStore.collection('conversations').doc(doc["id"]).get();
        if (!conversationRef.exists) continue;

        var participants = conversationRef.data()?["participants"];
        if (participants == null || participants.length < 2) continue;

        String otherUserId = currentUserId == participants[0]
            ? participants[1]
            : participants[0];

        var participantData =
            await fireStore.collection('users').doc(otherUserId).get();

        String lastMessage = doc["last message"];
        Timestamp lastMessageTime = doc["last message time"];

        newChats.add({
          "id": doc["id"],
          "name": participantData.data()?["name"] ?? "Unknown",
          "userId": participantData.id,
          "lastMessage": lastMessage,
          "timestamp": lastMessageTime,
          "bio": participantData.data()?["bio"] ?? "No bio available"
        });
      }

      if (!mounted) return;
      setState(() {
        isLoading = false;
        chats = newChats;
      });
    });
  }

  @override
  void dispose() {
    chatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
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
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : chats.isEmpty
              ? const Center(
                  child: Text(
                    "No recent chats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                ),
    );
  }
}
