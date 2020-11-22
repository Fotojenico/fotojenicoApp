import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fotojenico/screens/account.dart';
import 'package:fotojenico/screens/camera.dart';
import 'package:fotojenico/screens/home.dart';
import 'package:fotojenico/screens/rewards.dart';
import 'package:fotojenico/globals.dart';

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
        if(value != 1 && adToggle){
          try {
            myBanner?.dispose();
            myBanner = null;
          } catch (ex) {
            print('Failed to dispose ad');
          }
        }
        switch (value) {
          case 0:
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (c, a1, a2) => CameraScreen(),
                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
            break;
          case 1:
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (c, a1, a2) => HomeScreen(),
                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (c, a1, a2) => RewardsScreen(),
                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
            break;
          case 3:
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (c, a1, a2) => AccountScreen(),
                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
            break;
        }
      }
    },
    type: BottomNavigationBarType.fixed,
  );
}
