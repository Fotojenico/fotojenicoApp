import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

import 'package:fotojenico/globals.dart';
import 'package:fotojenico/navbar.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountState createState() {
    return _AccountState();
  }
}

class _AccountState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    String uid = '';
    if (user != null) {
      user.map((value) => uid = value.user.email, empty: (_) {}, initializing: (_) {});
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ExpandableSettingsTile(
              title: 'Visual settings',
              leading: Icon(Icons.palette),
              children: <Widget>[
                DropDownSettingsTile(title: 'Theme', settingKey: 'key-theme', selected: 0, values: <int, String>{
                  0: 'Amber',
                  1: 'Blue',
                  2: 'Red',
                  3: 'Green',
                }),
                SwitchSettingsTile(
                  settingKey: 'key-dark-mode',
                  title: 'Dark Mode',
                  enabledLabel: 'Enabled',
                  disabledLabel: 'Disabled',
                ),
              ],
            ),
            ExpandableSettingsTile(
              title: 'Account',
              leading: Icon(Icons.account_box),
              children: [
                Text(uid),
              ],
            ),
            SettingsContainer(
              children: [
                RaisedButton(
                  onPressed: () {
                    navContext.signOut();
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text('Sign out'),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: true,
        child: GestureDetector(
          onTap: () {
            //fav();
          },
          // ignore: missing_required_param
          child: FloatingActionButton(
            //tooltip: floatingActionTooltip,
            backgroundColor: Theme.of(context).backgroundColor,
            foregroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.check),
          ),
        ),
      ),
      bottomNavigationBar: navBar(context, 3),
    );
  }
}
