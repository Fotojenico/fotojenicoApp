import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget navBar(BuildContext context, int _selectedIndex) {
  return BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.camera_alt),
        label: 'Camera',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: FaIcon(FontAwesomeIcons.trophy),
        label: 'Rewards',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: 'Account',
      ),
    ],
    currentIndex: _selectedIndex,
    selectedItemColor: Theme.of(context).primaryColor,
    onTap: (value) {
      if (value != _selectedIndex) {
        switch (value) {
          case 0:
            Navigator.pushNamed(context, '/camera');
            break;
          case 1:
            Navigator.pushNamed(context, '/home');
            break;
          case 2:
            Navigator.pushNamed(context, '/rewards');
            break;
          case 3:
            Navigator.pushNamed(context, '/account');
            break;
        }
      }
    },
    type: BottomNavigationBarType.fixed,
  );
}
