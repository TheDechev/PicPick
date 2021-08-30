import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picpick/data/photo_repository.dart';

const int NUM_IMAGES_TO_SHOW = 4;

class GalleryScreen extends StatefulWidget {
  static const RouteKey = '/gallery_screen';

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final PhotoRepository photoRepo = PhotoGalleryRepository();
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
        ),
        backgroundColor: Colors.white,
        body: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: _gridChildren,
        ));
  }

  Future<void> _getPhotos() async {
    List<File> imageFiles =
        await photoRepo.fetchPhotoImages(NUM_IMAGES_TO_SHOW);
    print("fetched a total of ${imageFiles.length} images");
    List<Widget> widgets = [];
    for (var i = 0; i < NUM_IMAGES_TO_SHOW; i++) {
      print("adding widget i=$i");
      widgets.add(Container(
        child: Image.file(imageFiles[i]),
      ));
    }

    setState(() {
      _gridChildren = widgets;
    });
  }
}
