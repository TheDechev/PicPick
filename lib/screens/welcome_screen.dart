import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picpick/bloc/images_bloc.dart';
import 'package:picpick/data/photo_repository.dart';
import 'package:picpick/screens/gallery_screen.dart';
import 'package:picpick/screens/main_screen.dart';
//import 'package:photo_manager/photo_manager.dart';

class WelcomeScreen extends StatelessWidget {
  static const RouteKey = '/welcome_screen';

//  @override
//  void initState() {
//    PhotoManager.requestPermissionExtend().then((result) => {
//          if (result.isAuth)
//            {
//              // success
//            }
//          else
//            {
//              // fail
//              /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
//            }
//        });
//  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImagesBloc(PhotoGalleryRepository()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  'Welcome to PicPick!',
                  style: TextStyle(
                      fontSize: 60,
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, MainScreen.RouteKey);
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.pink,
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, GalleryScreen.RouteKey);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outlined),
                      Text(
                        'How To',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
