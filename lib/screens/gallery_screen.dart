import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:picpick/bloc/counter_bloc/counter_bloc.dart';
import 'package:picpick/bloc/images_bloc/images_bloc.dart';
import 'package:picpick/data/models/image_args.dart';
import 'package:picpick/data/models/image_file.dart';
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
  Map<int, ImageFile> _selectedItems = Map<int, ImageFile>();
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
            IconButton(
                onPressed: () {
                  _selectedItems.clear();
                  _imagesBloc.add(ReloadImages(NUM_IMAGES_TO_SHOW));
                  _counterBloc.add(CounterEvent.reset);
                },
                icon: Icon(Icons.clear_all)),
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity > 0) {
                    _imagesBloc.add(PreviousImages());
                  } else if (details.primaryVelocity < 0) {
                    _imagesBloc.add(NextImages());
                  }
                },
                child: Container(
                  child: BlocConsumer<ImagesBloc, ImagesState>(
                    listener: (context, state) {
                      if (state is ImagesDeleted) {
                        _imagesBloc.add(ReloadImages(NUM_IMAGES_TO_SHOW));
                      }
                    },
                    builder: (context, state) {
                      if (state is ImagesInitial || state is ImagesLoading) {
                        return _buildLoadIndicator();
                      } else if (state is ImagesLoaded) {
                        return _buildImagesUponLoad(context, state);
                      } else {
                        return Text("ERROR");
                      }
                    },
                  ),
                ),
              ),
            ),
            IconButton(
              iconSize: 35,
              onPressed: () {
                print('trash pressed - emptying');
                List<ImageFile> imageFiles = [];
                _selectedItems.forEach((k, v) => imageFiles.add(v));
                _imagesBloc.add(DeleteImages(imageFiles));
                _counterBloc.add(CounterEvent.reset);
                _selectedItems.clear();
              },
              icon: BlocBuilder<CounterBloc, int>(builder: (context, state) {
                return Badge(
                  showBadge: state > 0 ? true : false,
                  badgeColor: kBadgeColor,
                  animationType: BadgeAnimationType.slide,
                  badgeContent: Text(
                    state > 0 ? '$state' : '',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: Icon(
                    Icons.delete,
                    color: Colors.pinkAccent,
                  ),
                );
              }),
            ),
          ],
        ));
  }

  void _longPressedImage(File imageFile) {
    Navigator.pushNamed(context, ImageScreen.RouteKey,
        arguments: ImageArgs(
            imageFile: imageFile,
            heroTag: kImageHeroTag + imageFile.hashCode.toString()));
  }

  void _pressedImage(bool selected, ImageFile imageFile) {
    if (selected) {
      _counterBloc.add(CounterEvent.increment);
      print("image selected");
      _selectedItems[imageFile.hashCode] = imageFile;
    } else {
      print("image unselected");
      _counterBloc.add(CounterEvent.decrement);
      _selectedItems.remove(hashCode);
    }
  }

  Widget _buildHeroImageBox(
      int index, BuildContext context, ImagesLoaded event) {
    final bool isIndexInRange = index < event.imageFiles.length;

    return Hero(
      key: isIndexInRange ? ValueKey(event.imageFiles[index].hashCode) : null,
      tag: isIndexInRange
          ? kImageHeroTag + event.imageFiles[index].hashCode.toString()
          : kImageHeroTag,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: isIndexInRange
            ? ImageBox(
                selected: _selectedItems
                    .containsKey(event.imageFiles[index].hashCode),
                file: event.imageFiles[index].file,
                onLongPress: () {
                  _longPressedImage(event.imageFiles[index].file);
                },
                onPress: (selected) {
                  _pressedImage(selected, event.imageFiles[index]);
                },
                minHeight: (MediaQuery.of(context).size.height * 0.8) / 2.1,
              )
            : ImageBox(
                file: null,
                onPress: null,
                minHeight: (MediaQuery.of(context).size.height * 0.8) / 2.1,
              ),
      ),
    );
  }

  Widget _buildImagesUponLoad(BuildContext context, ImagesLoaded event) {
    print("fetched a total of ${event.imageFiles.length} images");

    return Row(children: [
      Expanded(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: NUM_IMAGES_TO_SHOW ~/ 2,
          itemBuilder: (context, index) {
            return _buildHeroImageBox(index, context, event);
          },
        ),
      ),
      Expanded(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: NUM_IMAGES_TO_SHOW ~/ 2,
          itemBuilder: (context, index) {
            index = NUM_IMAGES_TO_SHOW ~/ 2 + index;
            return _buildHeroImageBox(index, context, event);
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
