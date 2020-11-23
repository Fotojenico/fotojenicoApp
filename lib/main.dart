import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:fotojenico/screens/account.dart';
import 'package:fotojenico/screens/camera.dart';
import 'package:fotojenico/screens/home.dart';
import 'package:fotojenico/screens/rewards.dart';
import 'package:fotojenico/screens/send.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:fotojenico/globals.dart';
import 'dart:async';

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    if (adToggle){
      FirebaseAdMob.instance.initialize(appId: "ca-app-pub-3693041012036990~1825941193");
    }

    await Settings.init(cacheProvider: SharePreferenceCache());
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.code + " " + e.description);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]); // Used to disable top bar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => Home(),
        '/home': (_) => HomeScreen(),
        '/camera': (_) => CameraScreen(),
        '/rewards': (_) => RewardsScreen(),
        '/account': (_) => AccountScreen(),
        '/send': (_) => SendScreen(),
      },
      title: 'Fotojenico',
      theme: lightThemeList[Settings.getValue<int>('key-theme', 0)],
      darkTheme: darkThemeList[Settings.getValue<int>('key-theme', 0)],
      //home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LitAuthInit(
      authProviders: AuthProviders(
        emailAndPassword: true, // enabled by default
        google: true,
      ),
      child: LitAuthState(
        authenticated: HomeScreen(), // Login widget, or sign in button
        unauthenticated: Scaffold(body: LitAuth(),), // Authenticated widget, or sign out button
      ),
    );
  }
}
