import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picpick/utils/constants.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

const dummyImage = 'images/profile.jpeg';

class MainScreen extends StatefulWidget {
  static const RouteKey = '/main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _imageKey = GlobalKey();

  Size imageSize;
  int _numItemsDeleted = 0;

  getSizeAndPosition() {
    RenderBox _imageBox = _imageKey.currentContext.findRenderObject();
    imageSize = _imageBox.size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('PicPick'),
        elevation: 10,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            key: _imageKey,
            padding: const EdgeInsets.all(8.0),
            child: PositionedTapDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                child: Image.asset(
                  dummyImage,
                  fit: BoxFit.contain,
                ),
              ),
              onTap: (position) => _printTap('Single tap', position),
              onDoubleTap: (position) => _printTap('Double tap', position),
              onLongPress: (position) => _printTap('Long press', position),
//              doubleTapDelay: Duration(milliseconds: 800),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                iconSize: 30,
                onPressed: () {
                  print('trash pressed - emptying');
                  setState(() {
                    _numItemsDeleted = 0;
                  });
                },
                icon: Badge(
                  showBadge: _numItemsDeleted > 0 ? true : false,
                  badgeColor: kBadgeColor,
                  animationType: BadgeAnimationType.slide,
                  badgeContent: Text(
                    '$_numItemsDeleted',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: Icon(
                    Icons.delete,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  //todo: open gallery
                },
                icon: Icon(
                  Icons.broken_image, //todo: change to actual gallery image
                ),
                iconSize: 30,
                color: Colors.pinkAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _printTap(String gesture, TapPosition position) {
    getSizeAndPosition();
    double middleX = imageSize.width / 2;
    if (position.relative.dx > middleX) {
      print('right click');
    } else {
      print('left click');
      setState(() {
        _numItemsDeleted++;
      });
    }
  }
}
