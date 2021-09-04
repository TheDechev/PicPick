import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

abstract class PhotoRepository {
  Future<List<File>> fetchInitialPhotoImages(int numImages);
  Future<List<File>> getNextPhotoImages();
  List<File> getPreviousPhotoImages();
  void reset();
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
  int _numImages = 0,
      _lastAlbumIndex = 0,
      _lastStartFilesIndex = 0,
      _lastEndFilesIndex = 0;
  List<Album> _albums = [];
  List<File> _imageFiles = [];

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
  Future<List<File>> fetchInitialPhotoImages(int numImages) async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }

    _numImages = numImages;

    // Most likely the first time we load the images from local storage
    if (_albums.isEmpty) {
      _albums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
      print("this is the first load, creating the List<Album> object");
    }

    for (_lastAlbumIndex = 0;
        _lastAlbumIndex < _albums.length;
        _lastAlbumIndex++) {
      print("getting mediaPage for album index: $_lastAlbumIndex");
      MediaPage imagesPage = (await _albums[_lastAlbumIndex].listMedia());
      _imageFiles = _imageFiles + await _imagesPageToFileList(imagesPage);
      if (_imageFiles.length >= numImages) {
        print("got desired number of image files=$numImages");
        break;
      }
    }

    if (_imageFiles.length < numImages) {
      print(
          "requested numImages is lower than the actual number of images, returning actual number");
      numImages = _imageFiles.length;
    }

    _lastStartFilesIndex = 0;
    _lastEndFilesIndex = numImages - 1;

    return _imageFiles.sublist(_lastStartFilesIndex, _lastEndFilesIndex + 1);
  }

  @override
  void reset() {
    _numImages = 0;
    _albums.clear();
  }

  bool _enoughImageFiles() {
    return _imageFiles.length - _lastEndFilesIndex + 1 >= _numImages;
  }

  @override
  Future<List<File>> getNextPhotoImages() async {
    if (_numImages == 0 || _albums.isEmpty) {
      throw Exception(
          "Cannot retrieve next images before initial fetch, call fetchPhotoImages first");
    }

    if (!_enoughImageFiles()) {
      _lastAlbumIndex++;

      if (_lastAlbumIndex + 1 >= _albums.length) {
        print("reached the end of the album, returning the same images");
        return _imageFiles.sublist(
            _lastStartFilesIndex, _lastEndFilesIndex + 1);
      }

      while (_lastAlbumIndex < _albums.length) {
        print("getting mediaPage for album index: $_lastAlbumIndex");
        MediaPage imagesPage = (await _albums[_lastAlbumIndex].listMedia());
        _imageFiles = _imageFiles + await _imagesPageToFileList(imagesPage);
        if (_enoughImageFiles()) {
          print("got desired number of image files");
          break;
        }
      }
    }

    int index = _lastEndFilesIndex + _numImages;
    if (_imageFiles.length - (_lastEndFilesIndex + 1) < _numImages) {
      print(
          "requested numImages is lower than the actual number of images, returning actual number");
      index = _imageFiles.length - 1;
    }

    List<File> resList = _imageFiles.sublist(_lastEndFilesIndex + 1, index + 1);

    _lastStartFilesIndex = _lastEndFilesIndex + 1;
    _lastEndFilesIndex = index;

    return resList;
  }

  @override
  List<File> getPreviousPhotoImages() {
    if (_numImages == 0 || _albums.isEmpty) {
      throw Exception(
          "Cannot retrieve previous images before initial fetch, call fetchInitialPhotoImages first");
    }

    if (_lastStartFilesIndex != 0) {
      _lastStartFilesIndex -= _numImages;
      _lastEndFilesIndex = _lastStartFilesIndex + _numImages - 1;
    } else {
      print("reached first elements");
    }

    return _imageFiles.sublist(_lastStartFilesIndex, _lastEndFilesIndex + 1);
  }
}
