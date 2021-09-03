import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picpick/utils/constants.dart';

class ImageBox extends StatefulWidget {
  final File file;
  final Function onPress;

  ImageBox({@required this.file, @required this.onPress});

  @override
  _ImageBoxState createState() => _ImageBoxState();
}

class _ImageBoxState extends State<ImageBox> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPressed = !_isPressed;
        });
        widget.onPress();
      },
      child: Stack(
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (widget.file == null)
                    ? AssetImage(kDummyImageAsset)
                    : FileImage(widget.file),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          Container(
            height: 150,
            width: 150,
            color: Colors.pink[200].withOpacity(_isPressed ? 0.5 : 0),
          ),
        ],
      ),
    );
  }
}
