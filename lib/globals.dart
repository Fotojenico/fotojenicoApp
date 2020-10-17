import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

void logError(String code, String message) => print('Error: $code\nError Message: $message');

FirebaseAnalytics analytics = FirebaseAnalytics();
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
LitUser user;
List<CameraDescription> cameras = [];
bool cameraToggle = false;
bool imageToggle = false;
bool videoStartToggle = false;
bool videoEndToggle = false;
bool sentToggle = false;
bool sentScreenToggle = false;
String sentImage;
String sentVideo;
BuildContext navContext;

String webApiUrl = kDebugMode ? 'http://192.168.1.110:8000/api/' : 'https://fotojenico.com/api/';
List<ThemeData> lightThemeList = [
  ThemeData(
    primaryColor: Colors.amber[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  ThemeData(
    primaryColor: Colors.blue[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  ThemeData(
    primaryColor: Colors.red[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  ThemeData(
    primaryColor: Colors.green[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
];
List<ThemeData> darkThemeList = [
  ThemeData(
    primaryColor: Colors.amber[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  ThemeData(
    primaryColor: Colors.blue[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  ThemeData(
    primaryColor: Colors.red[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  ThemeData(
    primaryColor: Colors.green[800],
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
];
