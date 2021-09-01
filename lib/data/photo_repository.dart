import 'dart:io';

import 'package:flutter/material.dart';
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

  Future<List<File>> _imagesPageToFileList(MediaPage imagesPage) async {
    print("in _imagesPageToFileList");

    if (imagesPage.total == 0) {
      throw Exception("imagesPage is empty for some reason");
    }

    print("imagesPage total amount is: ${imagesPage.total}");
    List<File> imagesFileList = [];
    List<Medium> imagesMedium = imagesPage.items;
    bool isFirstPage = true;
    do {
      if (!isFirstPage) {
        imagesPage = await imagesPage.nextPage();
      }

      isFirstPage = false;

      for (var i = 0; i < imagesMedium.length; i++) {
        File imageFile = await imagesMedium[i].getFile();
        if (imageFile == null) {
          print("for some reason imageFile for i=$i is null");
          continue;
        }
        imagesFileList.add(imageFile);
      }
    } while (!imagesPage.isLast);

    if (imagesFileList.isEmpty) {
      print("imagesFileList is empty for some reason, throwing exception");
      throw Exception("imagesFile is empty for some reason");
    }

    return imagesFileList;
  }

  @override
  Future<List<File>> fetchPhotoImages(int numImages) async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }

    if (isFirstLoad) {
      _albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
      print("this is the first load, creating the List<Album> object");
    }

    isFirstLoad = false;

    List<File> imagesFile = [];

    for (var i = 0; i < _albums.length; i++) {
      print("getting mediaPage for album i=$i");
      MediaPage imagesPage = (await _albums[i].listMedia());
      imagesFile = imagesFile + await _imagesPageToFileList(imagesPage);
      if (imagesFile.length >= numImages) {
        print("got desired number of image files=$numImages");
        break;
      }
    }

    if (imagesFile.length < numImages) {
      print(
          "requested numImages is lower than the actual number of images, returning actual number");
      numImages = imagesFile.length;
    }

    return imagesFile.sublist(0, numImages);
  }
}
