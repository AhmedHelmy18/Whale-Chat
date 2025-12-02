import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/pages/chat.dart';
import 'package:whale_chat/controller/search_chat_controller.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController searchController = TextEditingController();
  final SearchUserController controller = SearchUserController();
  List<Map<String, dynamic>> searchResults = [];
  Timer? debounce;
  bool isLoading = false;

  void performSearch(String query) {
    debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      return;
    }

    debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => isLoading = true);

      final results = await controller.searchUsers(query.trim());

      if (mounted) {
        setState(() {
          searchResults = results;
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
              controller: searchController,
              onChanged: performSearch,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.black),
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
                    searchController.clear();
                    performSearch('');
                  },
                ),
                hintText: 'Search.....',
                hintStyle: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 20, left: 20),
            child: const Text(
              'Search Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                return ListTile(
                  title: Row(
                    children: [
                      ClipOval(
                        child: user['photoUrl']?.isNotEmpty == true
                            ? Image.network(user['photoUrl'],
                                width: 50, height: 50, fit: BoxFit.cover)
                            : Image.asset('assets/images/download.jpeg',
                                width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        user['name'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    final conversationId = await controller
                        .getOrCreateConversation(currentUserId, user['userId']);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            userId: user['userId'],
                            userName: user['name'],
                            conversationId: conversationId,
                            bio: user['bio'] ?? 'No bio available',
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
