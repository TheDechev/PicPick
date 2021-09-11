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
import 'package:shared_preferences/shared_preferences.dart';

import 'image_screen.dart';

enum DotsMenuItem { ClearAll, GridSize, ReportProblem }
const kGridSizeKey = 'grid_size';

class GalleryScreen extends StatefulWidget {
  static const RouteKey = '/gallery_screen';

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Map<int, ImageFile> _selectedItems = Map<int, ImageFile>();
  CounterBloc _counterBloc;
  ImagesBloc _imagesBloc;
  int _numImagesToShow;
  SharedPreferences _sharedPref;

  @override
  void initState() {
    _imagesBloc = BlocProvider.of<ImagesBloc>(context);
    _counterBloc = BlocProvider.of<CounterBloc>(context);
    SharedPreferences.getInstance().then((value) => _updatePage(value));

    super.initState();
  }

  @override
  void dispose() {
    _counterBloc.add(CounterEvent.reset);
    _imagesBloc.add(ResetImages());

    super.dispose();
  }

  bool _isSwipeLeft(DragEndDetails details) {
    return details.primaryVelocity > 0;
  }

  bool _isSwipeDown(DragEndDetails details) {
    return _isSwipeLeft(details); /*Same logic, just vertically*/
  }

  bool _isSwipeRight(DragEndDetails details) {
    return details.primaryVelocity < 0;
  }

  bool _isSwipeUp(DragEndDetails details) {
    return _isSwipeRight(details); /*Same logic, just vertically*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          )),
          title: Hero(tag: kPicPickHeroTag, child: Text('PicPick')),
          centerTitle: true,
          elevation: 6,
          actions: [
            PopupMenuButton(
              shape: kRoundedShape,
              color: Colors.pinkAccent,
              elevation: 8,
              onSelected: (item) => _selectedMenuItem(context, item),
              itemBuilder: (context) => [
                customPopupMenuItem(DotsMenuItem.ClearAll, "Clear All"),
                customPopupMenuItem(DotsMenuItem.GridSize, "Change grid"),
                customPopupMenuItem(
                    DotsMenuItem.ReportProblem, "Report a problem"),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onVerticalDragEnd: (DragEndDetails details) {
                if (_isSwipeDown(details)) {
                  print("swiped down");
                } else if (_isSwipeUp(details)) {
                  print("swiped up");
                }
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                if (_isSwipeLeft(details)) {
                  _imagesBloc.add(PreviousImages());
                } else if (_isSwipeRight(details)) {
                  _imagesBloc.add(NextImages());
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: BlocConsumer<ImagesBloc, ImagesState>(
                  listener: (context, state) {
                    if (state is ImagesDeleted) {
                      _imagesBloc.add(ReloadImages(_numImagesToShow));
                    }
                  },
                  builder: (context, state) {
                    if (state is ImagesInitial || state is ImagesLoading) {
                      return _buildLoadIndicator();
                    } else if (state is ImagesLoaded) {
                      // return _buildLoadIndicator();
                      return _buildImagesUponLoad(context, state);
                    } else {
                      return Text("ERROR");
                    }
                  },
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

  PopupMenuItem<DotsMenuItem> customPopupMenuItem(
      DotsMenuItem item, String text) {
    return PopupMenuItem<DotsMenuItem>(
        value: item,
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
      key: isIndexInRange
          ? ValueKey(event.imageFiles[index].hashCode)
          : ValueKey("image$index"),
      tag: isIndexInRange
          ? kImageHeroTag + event.imageFiles[index].hashCode.toString()
          : kImageHeroTag + index.toString(),
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
                minHeight: (MediaQuery.of(context).size.height * 0.8) /
                    (_numImagesToShow / 2) /
                    1.1,
              )
            : ImageBox(
                file: null,
                onPress: null,
                minHeight: (MediaQuery.of(context).size.height * 0.8) /
                    (_numImagesToShow / 2) /
                    1.1,
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
          itemCount: _numImagesToShow ~/ 2,
          itemBuilder: (context, index) {
            return _buildHeroImageBox(index, context, event);
          },
        ),
      ),
      Expanded(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _numImagesToShow ~/ 2,
          itemBuilder: (context, index) {
            index = _numImagesToShow ~/ 2 + index;
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

  void _reloadPage({int numImages = kDefaultNumImagesToShow}) {
    if (numImages != kDefaultNumImagesToShow) {
      _sharedPref.setInt(kGridSizeKey, numImages);
    }
    _numImagesToShow = numImages;
    _imagesBloc.add(ReloadImages(_numImagesToShow));
    _counterBloc.add(CounterEvent.reset);
    _selectedItems.clear();
  }

  void _selectedMenuItem(BuildContext context, DotsMenuItem item) {
    switch (item) {
      case DotsMenuItem.ClearAll:
        _selectedItems.clear();
        _imagesBloc.add(ReloadImages(_numImagesToShow));
        _counterBloc.add(CounterEvent.reset);
        break;
      case DotsMenuItem.GridSize:
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                elevation: 8,
                backgroundColor: Colors.pinkAccent,
                shape: kRoundedShape,
                title: Center(
                    child: Text(
                  "Select Grid Size",
                  style: kHeaderTextStyle,
                )),
                children: [
                  customDialogOption(context, 2),
                  customDialogOption(context, 4),
                  customDialogOption(context, 8)
                ],
              );
            });
        print("grid size selected");
        break;
      case DotsMenuItem.ReportProblem:
        print("report a problem selected");
        break;
      default:
        print("unknown value");
        break;
    }
  }

  SimpleDialogOption customDialogOption(BuildContext context, int num) {
    return SimpleDialogOption(
      child: Center(
        child: Text(
          num.toString(),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      onPressed: () {
        _reloadPage(numImages: num);
        Navigator.pop(context);
      },
    );
  }

  _updatePage(SharedPreferences value) {
    _sharedPref = value;
    _numImagesToShow =
        _sharedPref.getInt(kGridSizeKey) ?? kDefaultNumImagesToShow;
    _imagesBloc.add(GetImages(_numImagesToShow));
  }
}
