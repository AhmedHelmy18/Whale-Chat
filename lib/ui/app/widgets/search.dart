import 'package:chat_app/constants/theme.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<String> data = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grapes',
    'Honeydew',
    'Kiwi',
    'Lemon',
  ];

  List<String> searchResults = [];

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = data;
      } else {
        searchResults = data
            .where(
              (item) => item.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  void initState() {
    searchResults = data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(
            context,
          ),
          icon: Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
              onChanged: (value) => _search(value),
              controller: _searchController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 20, color: Colors.black),
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    width: 3,
                    color: colorScheme.primary,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurface,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                hintText: 'Search.....',
                hintStyle: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 30,
              bottom: 20,
              left: 20,
            ),
            child: Text(
              'Search Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    searchResults[index],
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
