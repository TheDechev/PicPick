import 'package:flutter/material.dart';
import 'package:picpick/utils/constants.dart';

class HowToScreen extends StatelessWidget {
  static const RouteKey = '/how_to_screen';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 16,
      backgroundColor: Colors.pinkAccent,
      shape: kRoundedShape,
      scrollable: false,
      title: Center(
        child: Text(
          'How To',
          style: kHeaderTextStyle,
        ),
      ),
      content: Container(
        height: (MediaQuery.of(context).size.height * 0.8) / 6,
        child: Text(
          "1) Select images you wish to delete\n\n"
          "2) Click on the trash icon to delete\n\n"
          "3) Profit",
          style: kBodyTextStyle,
        ),
      ),
    );
  }
}
