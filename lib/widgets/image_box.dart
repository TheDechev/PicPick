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
      @required this.onPress,
      @required this.minHeight,
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
      onLongPress: widget.onLongPress,
      onTap: () {
        setState(() {
          _selected = !_selected;
        });
        widget.onPress(_selected);
      },
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(minHeight: _minHeight),
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
            constraints: BoxConstraints(minHeight: _minHeight),
            color: Colors.pink[200].withOpacity(_selected ? 0.5 : 0),
          ),
        ],
      ),
    );
  }
}
