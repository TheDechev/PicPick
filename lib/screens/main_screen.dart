import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_image_provider/device_image.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:picpick/utils/constants.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:local_image_provider/local_image_provider.dart' as lip;

class MainScreen extends StatefulWidget {
  static const RouteKey = '/main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _imageKey = GlobalKey();
  List<LocalImage> _loadedImages;
  Size imageSize;
  int _numItemsDeleted = 0;
  bool _updatePicture = false;

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
                child: _getCurrentImage(),
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

  Widget _getCurrentImage() {
    return _loadedImages == null
        ? Image.asset(
            kDummyImageAsset,
            fit: BoxFit.contain,
          )
        : _loadedImages.isEmpty
            ? Image.asset(
                kDummyImageAsset,
                fit: BoxFit.contain,
              )
            : Image(
                image: DeviceImage(_loadedImages[_getRandomPictureIndex()]),
                fit: BoxFit.contain,
              );
  }

  int _getRandomPictureIndex() {
    var rng = new Random();

    if (_loadedImages == null) {
      print("error, shouldn't get here with an empty images");
      return 0;
    }

    if (_loadedImages.isEmpty) {
      print("error, for some reason the images are empty");
      return 0;
    }

    return rng.nextInt(_loadedImages.length);
  }

  Future<void> handleImages() async {
    lip.LocalImageProvider imageProvider = lip.LocalImageProvider();
    bool hasPermission = await imageProvider.initialize();
    if (hasPermission) {
      List<LocalImage> images = await imageProvider.findLatest(10);
      setState(() {
        _loadedImages = images;
      });
      print('got here, images count: ${images.length}');
      images.forEach((image) => print("The image id is: ${image.id}"));
    } else {
      print("The user has denied access to images on their device.");
    }
  }

  void _printTap(String gesture, TapPosition position) {
    getSizeAndPosition();
    double middleX = imageSize.width / 2;
    if (position.relative.dx > middleX) {
      print('right click');
      handleImages().onError((error, stackTrace) => {print("error")});
    } else {
      print('left click');
      setState(() {
        _numItemsDeleted++;
      });
    }
  }
}
