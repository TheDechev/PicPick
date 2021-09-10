import 'package:flutter/material.dart';
import 'package:picpick/screens/gallery_screen.dart';
import 'package:picpick/screens/how_to_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const RouteKey = '/welcome_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome to PicPick!',
                style: TextStyle(
                    fontSize: 60,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, GalleryScreen.RouteKey);
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.pink,
                )),
            TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return HowToScreen();
                      });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outlined),
                    Text(
                      'How To',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
