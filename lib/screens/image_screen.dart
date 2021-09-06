import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picpick/data/models/image_args.dart';

class ImageScreen extends StatelessWidget {
  static const RouteKey = '/image_screen';

  const ImageScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as ImageArgs;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        body: Center(
          child: Hero(
            tag: args.heroTag,
            child: Image.file(args.imageFile),
          ),
        ),
      ),
    );
  }
}
