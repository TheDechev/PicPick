import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import 'models/image_file.dart';

abstract class PhotoRepository {
  Future<List<ImageFile>> fetchInitialPhotoImages(int numImages);
  Future<List<ImageFile>> getNextPhotoImages();
  List<ImageFile> getPreviousPhotoImages();
  Future<void> reset();
}

class PhotoGalleryRepository implements PhotoRepository {
  int _numImages = 0,
      _lastAlbumIndex = 0,
      _lastStartFilesIndex = 0,
      _lastEndFilesIndex = 0;
  List<AssetPathEntity> _assetsAlbumList = [];
  List<ImageFile> _imageFiles = [];

  Future<List<ImageFile>> _imageAssetsToImageFileList(
      List<AssetEntity> imageAssets) async {
    print("in _imagesPageToFileList");

    if (imageAssets.isEmpty) {
      throw Exception("imagesPage is empty for some reason");
    }

    List<ImageFile> imageFiles = [];
    for (int i = 0; i < imageAssets.length; i++) {
      File file = await imageAssets[i].file;
      imageFiles.add(ImageFile(imageAssets[i].id, file));
    }

    if (imageFiles.isEmpty) {
      throw Exception("imageFiles is empty for some reason");
    }

    return imageFiles;
  }

  @override
  Future<List<ImageFile>> fetchInitialPhotoImages(int numImages) async {
    if (!await Permission.storage.isGranted) {
      //todo: check if below is necessary upon first usage
      // await Permission.storage.request();

      var result = await PhotoManager.requestPermissionExtend();
      if (result.isAuth) {
        print("permission granted");
      } else {
        throw Exception("permission failure");
      }
    }

    _numImages = numImages;

    if (_assetsAlbumList.isEmpty) {
      await PhotoManager.clearFileCache();
      print("this is the first load, creating the List<Album> object");
      _assetsAlbumList =
          await PhotoManager.getAssetPathList(type: RequestType.image);
    } else {
      print("images already loaded (cached), resetting indices");
      _lastStartFilesIndex = _lastEndFilesIndex = _lastAlbumIndex = 0;
      _imageFiles.clear();
    }

    for (_lastAlbumIndex = 1;
        _lastAlbumIndex < _assetsAlbumList.length;
        _lastAlbumIndex++) {
      print("getting images for album num: $_lastAlbumIndex");
      AssetPathEntity album = _assetsAlbumList[_lastAlbumIndex];
      List<AssetEntity> imageAssets = await album.assetList;
      _imageFiles =
          _imageFiles + await _imageAssetsToImageFileList(imageAssets);
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
  Future<void> reset() async {
    _assetsAlbumList.clear();
    _imageFiles.clear();
    _numImages =
        _lastStartFilesIndex = _lastEndFilesIndex = _lastAlbumIndex = 0;
    await PhotoManager.clearFileCache();
  }

  bool _enoughImageFiles() {
    return _imageFiles.length - (_lastEndFilesIndex + 1) >= _numImages;
  }

  @override
  Future<List<ImageFile>> getNextPhotoImages() async {
    if (_numImages == 0 || _imageFiles.isEmpty) {
      throw Exception(
          "Cannot retrieve next images before initial fetch, call fetchPhotoImages first");
    }

    if (!_enoughImageFiles()) {
      if (_lastAlbumIndex + 1 >= _assetsAlbumList.length) {
        if (_imageFiles.length - (_lastEndFilesIndex + 1) > 0) {
          print("returning last images");
          return _imageFiles.sublist(
              _lastEndFilesIndex + 1, _imageFiles.length);
        }
        print("reached the last album, returning the same images");
        return _imageFiles.sublist(
            _lastStartFilesIndex, _lastEndFilesIndex + 1);
      }

      _lastAlbumIndex++;
      while (_lastAlbumIndex < _assetsAlbumList.length) {
        //todo: convert below to a function and use both here and initial fetch
        print("getting images for album num: $_lastAlbumIndex");
        AssetPathEntity album = _assetsAlbumList[_lastAlbumIndex];
        List<AssetEntity> imageAssets = await album.assetList;
        _imageFiles =
            _imageFiles + await _imageAssetsToImageFileList(imageAssets);

        if (_enoughImageFiles()) {
          print("got desired number of image files");
          break;
        }
        _lastAlbumIndex++;
      }
    }

    int index = _lastEndFilesIndex + _numImages;
    if (_imageFiles.length - (_lastEndFilesIndex + 1) < _numImages) {
      print(
          "requested numImages is lower than the actual number of images, returning actual number");
      index = _imageFiles.length - 1;
    }

    List<ImageFile> resList =
        _imageFiles.sublist(_lastEndFilesIndex + 1, index + 1);

    _lastStartFilesIndex = _lastEndFilesIndex + 1;
    _lastEndFilesIndex = index;

    return resList;
  }

  @override
  List<ImageFile> getPreviousPhotoImages() {
    if (_numImages == 0 || _assetsAlbumList.isEmpty) {
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
