import 'dart:developer';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/pages/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  void performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      setState(() {
        searchResults = snapshot.docs
            .map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return {
                'userId': doc.id,
                'name': data['name'] ?? 'Unknown',
              };
            })
            .where((user) =>
                user['userId'] != currentUserId) // Remove current user
            .toList();
      });
    } catch (e) {
      log('Error fetching search results: $e');
    }
  }

  Future<String> getOrCreateConversation(String userId1, String userId2) async {
    var conversationRef = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContainsAny: [userId1, userId2]).get();

    if (conversationRef.docs.isNotEmpty) {
      for (var doc in conversationRef.docs) {
        if (doc['participants'].contains(userId1) &&
            doc['participants'].contains(userId2)) {
          return doc.id;
        }
      }
    }

    var conversation =
        await FirebaseFirestore.instance.collection('conversations').add({
      'participants': [userId1, userId2],
    });
    log('Conversation created: ${conversation.id}');
    return conversation.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
              onChanged: performSearch,
              controller: _searchController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(width: 3, color: colorScheme.primary),
                ),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurface),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchResults = [];
                    });
                  },
                ),
                hintText: 'Search.....',
                hintStyle: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 20, left: 20),
            child: Text(
              'Search Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
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
                      Text(
                        searchResults[index]['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    String selectedUserId = searchResults[index]['userId'];
                    String selectedUserName = searchResults[index]['name'];
                    String currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    String? selectedUserBio = searchResults[index]['bio'];

                    String conversationId = await getOrCreateConversation(
                        currentUserId, selectedUserId);

                    if (!mounted) return;
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            userId: selectedUserId,
                            userName: selectedUserName,
                            conversationId: conversationId,
                            bio: selectedUserBio ?? 'No bio available',
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
