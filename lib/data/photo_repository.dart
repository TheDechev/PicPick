import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

abstract class PhotoRepository {
  Future<List<File>> fetchPhotoImages(int numImages);
}

/*
*  1) List of albums needs to be fetched.
*  2) The list from (1) needs to be converted to a MediaPage
*  3) The iteration should be done per page
* e.g.:
*   if (!imagePage.isLast) {
    final nextImagePage = await imagePage.nextPage();
    // ...
}
*
* */

class PhotoGalleryRepository implements PhotoRepository {
  static List<Album> _albums;
  static bool isFirstLoad = true;

  Future<List<File>> _imagesMediumListToFileList(
      List<Medium> imagesMedia) async {
    print("in _imagesMediumListToFileList");

    if (imagesMedia.isEmpty) {
      print("imagesMedia is empty for some reason, throwing exception");
      throw Exception("imagesMedia is empty for some reason");
    }

    List<File> imagesFileList = [];
    for (var i = 0; i < imagesMedia.length; i++) {
      File imageFile = await imagesMedia[i].getFile();
      if (imageFile == null) {
        print("for some reason imageFile for i=$i is null");
        continue;
      }
      imagesFileList.add(imageFile);
    }

    if (imagesFileList.isEmpty) {
      print("imagesFileList is empty for some reason, throwing exception");
      throw Exception("imagesFile is empty for some reason");
    }

    return imagesFileList;
  }

  @override
  Future<List<File>> fetchPhotoImages(int numImages) async {
    await Permission.storage.request();

    if (isFirstLoad) {
      _albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
      print("this is the first load, creating the List<Album> object");
    }

    isFirstLoad = false;

    List<File> imagesFile = [];

    for (var i = 0; i < _albums.length; i++) {
      print("getting mediaPage for album 0");
      //TODO: need to check all the pages in an album
      //TODO: need to check the next album if all the pages are done
      List<Medium> imagesMedia = (await _albums[i].listMedia()).items;
      imagesFile = imagesFile + await _imagesMediumListToFileList(imagesMedia);
      //TODO: need to actually make sure we fetch ONLY the amount required using the photo gallery package
      if (imagesFile.length >= numImages) {
        print("got desired number of image files=$numImages");
        break;
      }
    }

    if (imagesFile.length < numImages) {
      throw Exception(
          "number of images retreived is less than the number required: $numImages");
    }

    return imagesFile;
  }
}
