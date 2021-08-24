import 'package:flutter/material.dart';
import 'package:picpick/screens/main_screen.dart';
import 'package:picpick/utils/constants.dart';

class WelcomeScreen extends StatelessWidget {
  static const RouteKey = '/welcome_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'Welcome to PicPick!',
                style: TextStyle(
                    fontSize: 60,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.w700),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pushNamed(context, MainScreen.RouteKey);
              },
              child: Container(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.pink,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
