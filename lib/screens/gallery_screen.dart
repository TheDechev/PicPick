import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
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
const kDummyValue = -1;

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
  List<ImageFile> _shownImageFiles = [];

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
                  print(
                      "swipe down, _shownImageFiles.length=${_shownImageFiles.length}");
                  // _selectedItems.removeWhere((key, value) => _shownImageFiles.contains(value));
                  for (var i = 0; i < _shownImageFiles.length; i++) {
                    if (_selectedItems
                        .containsKey(_shownImageFiles[i].hashCode)) {
                      _selectedItems.remove(_shownImageFiles[i].hashCode);
                      _counterBloc.add(CounterEvent.decrement);
                    }
                  }
                  _imagesBloc.add(ReloadImages(_numImagesToShow));
                } else if (_isSwipeUp(details)) {
                  print(
                      "swipe up, _shownImageFiles.length=${_shownImageFiles.length}");
                  for (var i = 0; i < _shownImageFiles.length; i++) {
                    if (!_selectedItems
                        .containsKey(_shownImageFiles[i].hashCode)) {
                      _selectedItems[_shownImageFiles[i].hashCode] =
                          _shownImageFiles[i];
                      _counterBloc.add(CounterEvent.increment);
                    }
                  }
                  _imagesBloc.add(ReloadImages(_numImagesToShow));
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
                      _reloadPage();
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
      _selectedItems.remove(imageFile.hashCode);
    }
  }

  Widget _buildHeroImageBox(int index, BuildContext context,
      ImageFile imageFile, bool isIndexInRange) {
    final double minHeight = (MediaQuery.of(context).size.height * 0.8) /
        (_numImagesToShow / 2) /
        1.1;
    final ImageBox imageBox = isIndexInRange
        ? buildImageBox(imageFile, context, minHeight)
        : ImageBox(
            file: null,
            onPress: null,
            minHeight: minHeight,
          );

    return Hero(
      key: isIndexInRange
          ? ValueKey(imageFile.hashCode)
          : ValueKey("image$index"),
      tag: isIndexInRange
          ? kImageHeroTag + imageFile.hashCode.toString()
          : kImageHeroTag + index.toString(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: imageBox,
      ),
    );
  }

  ImageBox buildImageBox(
      ImageFile imageFile, BuildContext context, double minHeight) {
    return ImageBox(
      opaque: imageFile,
      selected: _selectedItems.containsKey(imageFile.hashCode),
      file: imageFile.file,
      onLongPress: () {
        _longPressedImage(imageFile.file);
      },
      onPress: (selected) {
        _pressedImage(selected, imageFile);
      },
      minHeight: minHeight,
    );
  }

  Widget _buildImages(BuildContext context, List<ImageFile> imageFiles) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _numImagesToShow ~/ 2,
            itemBuilder: (context, index) {
              final bool isIndexInRange = index < imageFiles.length;
              return _buildHeroImageBox(index, context,
                  isIndexInRange ? imageFiles[index] : null, isIndexInRange);
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
              final bool isIndexInRange = index < imageFiles.length;
              return _buildHeroImageBox(index, context,
                  isIndexInRange ? imageFiles[index] : null, isIndexInRange);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImagesUponLoad(BuildContext context, ImagesLoaded event) {
    print("fetched a total of ${event.imageFiles.length} images");

    _shownImageFiles = event.imageFiles;

    return _buildImages(context, event.imageFiles);
  }

  Widget _buildLoadIndicator() {
    return LoadingIndicator(
      indicatorType: Indicator.ballClipRotateMultiple,
      strokeWidth: 2,
    );
  }

  void _reloadPage(
      {int numImages = kDummyValue,
      bool resetSelected = true,
      bool resetCounter = true}) {
    if (numImages != kDummyValue) {
      _sharedPref.setInt(kGridSizeKey, numImages);
      _numImagesToShow = numImages;
    }

    _imagesBloc.add(ReloadImages(_numImagesToShow));

    if (resetCounter) {
      _counterBloc.add(CounterEvent.reset);
    }

    if (resetSelected) {
      _selectedItems.clear();
    }
  }

  void _selectedMenuItem(BuildContext context, DotsMenuItem item) {
    switch (item) {
      case DotsMenuItem.ClearAll:
        _reloadPage();
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
                  customGridDialogOption(context, 2),
                  customGridDialogOption(context, 4),
                  customGridDialogOption(context, 8)
                ],
              );
            });
        print("grid size selected");
        break;
      case DotsMenuItem.ReportProblem:
        _sendAReportEmail().then((value) => () {
              print("email sent");
            });
        print("report a problem selected");
        break;
      default:
        print("unknown value");
        break;
    }
  }

  SimpleDialogOption customGridDialogOption(BuildContext context, int num) {
    return SimpleDialogOption(
      child: Center(
        child: Text(
          num.toString(),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      onPressed: () {
        _reloadPage(numImages: num, resetCounter: false, resetSelected: false);
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

  Future<void> _sendAReportEmail() async {
    final Email email = Email(
      body: 'This is a test report from the PicPick application.',
      subject: 'PicPick report',
      recipients: ['enter email here'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      print("cannot send an email, exception=${e.toString()}");
    }
  }
}
