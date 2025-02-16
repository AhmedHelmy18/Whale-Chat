import 'package:chat_app/constants/theme.dart';
import 'package:chat_app/ui/app/pages/add_friend.dart';
import 'package:chat_app/ui/app/pages/home_page.dart';
import 'package:chat_app/ui/app/widgets/search.dart';
import 'package:flutter/material.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int selectedIndex = 0;
  List<Widget> pages = [
    HomePage(),
    AddFriend(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: colorScheme.primary,
        title: selectedIndex == 0
            ? Text(
                'Chat',
                style: TextStyle(
                  fontSize: 30,
                  color: colorScheme.surface,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                'Add Friend',
                style: TextStyle(
                  fontSize: 25,
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
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(
          size: 30,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 25,
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Friend',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.secondary,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
