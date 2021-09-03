import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picpick/bloc/images_bloc.dart';
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
    final imagesBloc = BlocProvider.of<ImagesBloc>(context);
    imagesBloc.add(GetImages(NUM_IMAGES_TO_SHOW));

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
                    child: BlocBuilder<ImagesBloc, ImagesState>(
                      builder: (context, state) {
                        if (state is ImagesInitial) {
                          return Text("Initial");
                        } else if (state is ImagesLoading) {
                          return Text("Loading");
                        } else if (state is ImagesLoaded) {
                          return _buildImagesUponLoad(state);
                        } else {
                          return Text("ERROR");
                        }
                      },
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

  Widget _buildImagesUponLoad(ImagesLoaded event) {
    print("fetched a total of ${event.imageFiles.length} images");

    List<Widget> widgets = [];
    for (var i = 0; i < NUM_IMAGES_TO_SHOW; i++) {
      print("adding widget i=$i");
      widgets.add(ImageBox(
        file: (i < event.imageFiles.length) ? event.imageFiles[i] : null,
        onPress: () {
          print("image pressed");
        },
      ));
    }

    return Column(
      children: [
        widgets[0],
        widgets[1],
        widgets[2],
        widgets[3],
      ],
    );
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
