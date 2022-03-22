import 'package:flutter/material.dart';
import 'package:manga_reader/pages/extra/statistics_page.dart';
import 'package:manga_reader/pages/reading_page.dart';
import 'package:manga_reader/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ReadingPage(),
    Text(
      'owo',
      style: optionStyle,
    ),
    SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga'),
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) async {
                switch (item) {
                  case 0:
                    // logout
                    final instance = await SharedPreferences.getInstance();
                    instance.remove('token');
                    Navigator.pushReplacementNamed(context, 'login');
                    break;
                  case 1:
                    // stats
                    Navigator.pushNamed(context, StatisticsPage.routeName);
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) => const [
                    PopupMenuItem(
                      value: 0,
                      child: Text('Logout'),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text('Statistics'),
                    )
                  ]),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            label: 'Hot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
