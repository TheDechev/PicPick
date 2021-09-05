import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picpick/utils/constants.dart';

class ImageBox extends StatefulWidget {
  final File file;
  final Function onPress;
  final Function onLongPress;
  final bool selected;
  final double minHeight;

  ImageBox(
      {@required this.file,
      @required this.minHeight,
      this.onPress,
      this.selected = false,
      this.onLongPress});

  @override
  _ImageBoxState createState() => _ImageBoxState(selected, minHeight);
}

class _ImageBoxState extends State<ImageBox> {
  bool _selected = false;
  final double _minHeight;

  _ImageBoxState(this._selected, this._minHeight);

  bool get selected => _selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.onLongPress != null) {
          widget.onLongPress();
        }
      },
      onTap: () {
        if (widget.onPress != null) {
          setState(() {
            _selected = !_selected;
          });
          widget.onPress(_selected);
        }
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            constraints: BoxConstraints(minHeight: _minHeight),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              image: DecorationImage(
                image: (widget.file == null)
                    ? AssetImage(kNoImageAsset)
                    : FileImage(widget.file),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          // Container(
          //   constraints: BoxConstraints(minHeight: _minHeight),
          //   color: Colors.pink[200].withOpacity(_selected ? 0.5 : 0),
          // ),
          _selected
              ? Icon(
                  Icons.check_circle,
                  size: _minHeight / 6,
                  color: kBadgeColor,
                )
              : Container()
        ],
      ),
    );
  }
}
