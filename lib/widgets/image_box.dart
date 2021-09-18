import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:picpick/utils/constants.dart';

class ImageBox extends StatefulWidget {
  final Uint8List bytes;
  final Function onPress;
  final Function onLongPress;
  final bool selected;
  final double minHeight;
  final Object opaque;

  ImageBox(
      {@required this.bytes,
      @required this.minHeight,
      this.onPress,
      this.selected = false,
      this.onLongPress,
      this.opaque});

  @override
  _ImageBoxState createState() => _ImageBoxState(selected, minHeight);
}

class _ImageBoxState extends State<ImageBox> {
  bool _selected = false;
  double _minHeight;

  _ImageBoxState(this._selected, this._minHeight);

  bool get selected => _selected;

  @override
  void didUpdateWidget(ImageBox oldWidget) {
    if (_minHeight != widget.minHeight) {
      print("force reload due to height property");
      setState(() {
        _minHeight = widget.minHeight;
      });
    } else if (_selected != widget.selected) {
      print("force reload due to selected property");
      setState(() {
        _selected = widget.selected;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  set selected(bool value) {
    setState(() {
      _selected = value;
    });
  }

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
            constraints: BoxConstraints(
              minHeight: _minHeight,
            ),
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
                image: (widget.bytes == null)
                    ? AssetImage(kNoImageAsset)
                    : MemoryImage(widget.bytes),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            size: _minHeight / 7,
            color: _selected ? kBadgeColor : Colors.transparent,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(_selected ? 0.3 : 0),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            height: _minHeight,
          )
        ],
      ),
    );
  }
}
