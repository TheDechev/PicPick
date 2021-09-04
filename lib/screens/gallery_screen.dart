import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picpick/bloc/counter_bloc/counter_bloc.dart';
import 'package:picpick/bloc/images_bloc/images_bloc.dart';
import 'package:picpick/data/photo_repository.dart';
import 'package:picpick/utils/constants.dart';
import 'package:picpick/widgets/image_box.dart';

const int NUM_IMAGES_TO_SHOW = 4;

class GalleryScreen extends StatefulWidget {
  static const RouteKey = '/gallery_screen';

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final PhotoRepository photoRepo = PhotoGalleryRepository();

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
                    final imagesBloc = BlocProvider.of<ImagesBloc>(context);
                    imagesBloc.add(PreviousImages());
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.pink,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: BlocBuilder<ImagesBloc, ImagesState>(
                      builder: (context, state) {
                        if (state is ImagesInitial) {
                          return Text("Initial");
                        } else if (state is ImagesLoading) {
                          return Text("Loading");
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
                    final imagesBloc = BlocProvider.of<ImagesBloc>(context);
                    imagesBloc.add(NextImages());
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
                final counterBloc = BlocProvider.of<CounterBloc>(context);
                counterBloc.add(CounterEvent.reset);
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
}

List<Widget> _convertImageFilesToWidgetList(
    BuildContext context, ImagesLoaded event) {
  List<Widget> widgets = [];

  for (var i = 0; i < NUM_IMAGES_TO_SHOW; i++) {
    print("adding widget i=$i");
    widgets.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: ImageBox(
          selected: false,
          file: (i < event.imageFiles.length) ? event.imageFiles[i] : null,
          onPress: (selected) {
            final counterBloc = BlocProvider.of<CounterBloc>(context);
            if (selected) {
              counterBloc.add(CounterEvent.increment);
              print("image selected");
            } else {
              print("image unselected");
              counterBloc.add(CounterEvent.decrement);
            }
          },
        ),
      ),
    );
  }

  return widgets;
}

Widget _buildImagesUponLoad(BuildContext context, ImagesLoaded event) {
  print("fetched a total of ${event.imageFiles.length} images");

  List<Widget> widgets = _convertImageFilesToWidgetList(context, event);

  return Row(
    children: [
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
    ],
  );
}
