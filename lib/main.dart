import 'package:flutter/material.dart';
import 'package:picpick/screens/gallery_screen.dart';
import 'package:picpick/screens/main_screen.dart';
import 'package:picpick/screens/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: WelcomeScreen.RouteKey,
      routes: {
        WelcomeScreen.RouteKey: (context) => WelcomeScreen(),
        MainScreen.RouteKey: (context) => MainScreen(),
        GalleryScreen.RouteKey: (context) => GalleryScreen()
      },
    );
  }
}
