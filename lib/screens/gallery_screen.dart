import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:picpick/data/photo_repository.dart';
import 'package:picpick/utils/constants.dart';

const int NUM_IMAGES_TO_SHOW = 4;

class GalleryScreen extends StatefulWidget {
  static const RouteKey = '/gallery_screen';

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final PhotoRepository photoRepo = PhotoGalleryRepository();
  int _numItemsToDelete = 0;

  List<Widget> _gridChildren = [
    Container(
        decoration: BoxDecoration(color: Colors.blue), child: Text("test")),
    Container(
        decoration: BoxDecoration(color: Colors.yellow), child: Text("test2")),
    Container(
        decoration: BoxDecoration(color: Colors.orange), child: Text("test3")),
    Container(
        decoration: BoxDecoration(color: Colors.red), child: Text("test4"))
  ];

  @override
  void initState() {
    _getPhotos();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gallery'),
          centerTitle: true,
          elevation: 10,
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    print("back button pressed");
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.pink,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 300,
                    width: 350,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: _gridChildren,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    print("forward button pressed");
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            IconButton(
              iconSize: 35,
              onPressed: () {
                print('trash pressed - emptying');
                setState(() {
                  _numItemsToDelete = 0;
                });
              },
              icon: Badge(
                showBadge: _numItemsToDelete > 0 ? true : false,
                badgeColor: kBadgeColor,
                animationType: BadgeAnimationType.slide,
                badgeContent: Text(
                  '$_numItemsToDelete',
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
          ],
        ));
  }

  Future<void> _getPhotos() async {
    List<File> imageFiles =
        await photoRepo.fetchPhotoImages(NUM_IMAGES_TO_SHOW);
    print("fetched a total of ${imageFiles.length} images");
    List<Widget> widgets = [];
    for (var i = 0; i < imageFiles.length; i++) {
      print("adding widget i=$i");
      widgets.add(ImageBox(
        file: imageFiles[i],
        onPress: () {
          print("image pressed");
        },
      ));
    }

    setState(() {
      _gridChildren = widgets;
    });
  }
}

class ImageBox extends StatelessWidget {
  final File file;
  final Function onPress;

  ImageBox({@required this.file, @required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                (file == null) ? AssetImage(kDummyImageAsset) : FileImage(file),
            fit: BoxFit.cover,
          ),
          color: Colors.yellow,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}
