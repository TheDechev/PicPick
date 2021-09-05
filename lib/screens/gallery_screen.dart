import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:picpick/bloc/counter_bloc/counter_bloc.dart';
import 'package:picpick/bloc/images_bloc/images_bloc.dart';
import 'package:picpick/data/models/ImageArgs.dart';
import 'package:picpick/data/photo_repository.dart';
import 'package:picpick/utils/constants.dart';
import 'package:picpick/widgets/image_box.dart';

import 'image_screen.dart';

const int NUM_IMAGES_TO_SHOW = 4;

class GalleryScreen extends StatefulWidget {
  static const RouteKey = '/gallery_screen';

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Set _selectedItems = Set();
  CounterBloc _counterBloc;
  ImagesBloc _imagesBloc;

  @override
  void initState() {
    _imagesBloc = BlocProvider.of<ImagesBloc>(context);
    _counterBloc = BlocProvider.of<CounterBloc>(context);

    _imagesBloc.add(GetImages(NUM_IMAGES_TO_SHOW));

    super.initState();
  }

  @override
  void dispose() {
    _counterBloc.add(CounterEvent.reset);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gallery'),
          centerTitle: true,
          elevation: 10,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.clear_all)),
          ],
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
                    _imagesBloc.add(PreviousImages());
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.pink,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: BlocBuilder<ImagesBloc, ImagesState>(
                      builder: (context, state) {
                        if (state is ImagesInitial || state is ImagesLoading) {
                          return _buildLoadIndicator();
                        } else if (state is ImagesLoaded) {
                          return _buildImagesUponLoad(context, state);
/*                          return Column(
                              children:
                                  .map((e) => Flexible(child: e))
                                  .toList());*/
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
                    _imagesBloc.add(NextImages());
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
                _counterBloc.add(CounterEvent.reset);
                _selectedItems.clear();
                _imagesBloc.add(ReloadImages(NUM_IMAGES_TO_SHOW));
              },
              icon: BlocBuilder<CounterBloc, int>(builder: (context, state) {
                if (state > 0) {
                  return Badge(
                    showBadge: true,
                    badgeColor: kBadgeColor,
                    animationType: BadgeAnimationType.slide,
                    badgeContent: Text(
                      '$state',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.pinkAccent,
                    ),
                  );
                } else {
                  return Icon(
                    Icons.delete,
                    color: Colors.pinkAccent,
                  );
                }
              }),
            ),
          ],
        ));
  }

  List<Widget> _convertImageFilesToWidgetList(
      BuildContext context, ImagesLoaded event) {
    List<Widget> widgets = [];

    for (var i = 0; i < NUM_IMAGES_TO_SHOW; i++) {
      bool isIndexInRange = i < event.imageFiles.length;
      print("adding widget i=$i");
      widgets.add(
        Hero(
          key: isIndexInRange ? ValueKey(event.imageFiles[i].hashCode) : null,
          tag: isIndexInRange
              ? kImageHeroTag + event.imageFiles[i].hashCode.toString()
              : kImageHeroTag,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: isIndexInRange
                ? ImageBox(
                    selected:
                        _selectedItems.contains(event.imageFiles[i].hashCode),
                    file: event.imageFiles[i],
                    onLongPress: () {
                      _longPressedImage(event.imageFiles[i]);
                    },
                    onPress: (selected) {
                      _pressedImage(selected, event.imageFiles[i].hashCode);
                    },
                    minHeight: (MediaQuery.of(context).size.height * 0.8) / 2.1,
                  )
                : ImageBox(
                    file: null,
                    onPress: null,
                    minHeight: (MediaQuery.of(context).size.height * 0.8) / 2.1,
                  ),
          ),
        ),
      );
    }

    return widgets;
  }

  void _longPressedImage(File imageFile) {
    Navigator.pushNamed(context, ImageScreen.RouteKey,
        arguments: ImageArgs(
            imageFile: imageFile,
            heroTag: kImageHeroTag + imageFile.hashCode.toString()));
  }

  void _pressedImage(bool selected, int hashCode) {
    if (selected) {
      _counterBloc.add(CounterEvent.increment);
      print("image selected");
      _selectedItems.add(hashCode);
    } else {
      print("image unselected");
      _counterBloc.add(CounterEvent.decrement);
      _selectedItems.remove(hashCode);
    }
  }

  Widget _buildImagesUponLoad(BuildContext context, ImagesLoaded event) {
    print("fetched a total of ${event.imageFiles.length} images");

    List<Widget> widgets = _convertImageFilesToWidgetList(context, event);

    return Row(children: [
      Expanded(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widgets.length ~/ 2,
          itemBuilder: (context, index) {
            print("index=$index");
            return widgets[index];
          },
        ),
      ),
      Expanded(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widgets.length ~/ 2,
          itemBuilder: (context, index) {
            index = widgets.length ~/ 2 + index;
            print("index=$index");
            return widgets[index];
          },
        ),
      ),
    ]);
  }

  Widget _buildLoadIndicator() {
    return LoadingIndicator(
      indicatorType: Indicator.ballClipRotateMultiple,
      strokeWidth: 2,
    );
  }
}
