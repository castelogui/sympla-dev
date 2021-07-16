import 'package:flutter/material.dart';
import 'package:sympla_dev/pages/exploreSymplaDev.dart';
import 'package:sympla_dev/pages/favoriteEventSymplaDev.dart';
import 'package:sympla_dev/pages/homeSymplaDev.dart';
import 'package:sympla_dev/pages/loginSymplaDev.dart';

class BodySimplaDev extends StatefulWidget {
  const BodySimplaDev({Key? key}) : super(key: key);

  @override
  _BodySimplaDevState createState() => _BodySimplaDevState();
}

class _BodySimplaDevState extends State<BodySimplaDev> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomeSymplaDev(),
    ExploreSymplaDev(),
    FavoriteEventSymplaDev(),
    LoginSymplaDev()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
        selectedFontSize: 12,
      ),
    );
  }
}
