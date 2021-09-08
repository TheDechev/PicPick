import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  static const RouteKey = '/how_to_screen';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: false,
      title: Center(child: Text('How To')),
      content: Container(
        height: (MediaQuery.of(context).size.height * 0.8) / 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
            "1)Select images you wish to delete\n\n2)Click on the trash icon to delete\n\n3)Profit"),
      ),
    );
  }
}
