import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import 'models/image_file.dart';

abstract class PhotoRepository {
  Future<List<ImageFile>> fetchInitialPhotoImages(int numImages);
  Future<List<ImageFile>> getNextPhotoImages();
  List<ImageFile> getPreviousPhotoImages();
  Future<void> reset();
  Future<void> deleteImages(List<ImageFile> imagesFilesToDelete);
  List<ImageFile> reloadImages(int numImages);
}

class PhotoGalleryRepository implements PhotoRepository {
  int _numImages = 0,
      _lastAlbumIndex = 0,
      _lastStartFilesIndex = 0,
      _lastEndFilesIndex = 0,
      _lastStartAssetRange = 0,
      _lastEndAssetRange = 0;
  AssetPathEntity _lastAlbum;
  List<AssetPathEntity> _assetsAlbumList = [];
  List<ImageFile> _imageFiles = [];

  @override
  Future<void> reset() async {
    _assetsAlbumList.clear();
    _imageFiles.clear();
    _numImages = _lastStartFilesIndex = _lastEndFilesIndex =
        _lastAlbumIndex = _lastStartAssetRange = _lastEndAssetRange = 0;
    await PhotoManager.clearFileCache();
    _lastAlbum = null;
  }

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

  Future<void> _fetchMoreFilesFromAlbum() async {
    while (_lastAlbum.assetCount > _lastEndAssetRange && !_enoughImageFiles()) {
      _lastStartAssetRange = _lastEndAssetRange;
      _lastEndAssetRange = _lastEndAssetRange + _numImages;
      List<AssetEntity> imageAssets = await _lastAlbum.getAssetListRange(
          start: _lastStartAssetRange, end: _lastEndAssetRange);
      _imageFiles =
          _imageFiles + await _imageAssetsToImageFileList(imageAssets);
    }
  }

  @override
  Future<List<ImageFile>> fetchInitialPhotoImages(int numImages) async {
    if (!await Permission.storage.isGranted) {
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
      FilterOption filter =
          FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true));
      FilterOptionGroup optionGroup = FilterOptionGroup(imageOption: filter);
      _assetsAlbumList = await PhotoManager.getAssetPathList(
          type: RequestType.image, filterOption: optionGroup);
    } else {
      print("images already loaded (cached), resetting indices");
      _lastStartFilesIndex = _lastEndFilesIndex = _lastAlbumIndex = 0;
      _imageFiles.clear();
    }

    if (_assetsAlbumList.isEmpty) {
      print("error - no albums");
      return [];
    }

    for (_lastAlbumIndex = 0;
        _lastAlbumIndex < _assetsAlbumList.length;
        _lastAlbumIndex++) {
      print("getting images for album num: $_lastAlbumIndex");
      _lastAlbum = _assetsAlbumList[_lastAlbumIndex];

      await _fetchMoreFilesFromAlbum();

      if (_lastAlbum.isAll) {
        print("album contains all images, not going to use _lastAlbumIndex");
        break;
      } else if (_imageFiles.length >= numImages) {
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

  bool _enoughImageFiles() {
    return _imageFiles.length - (_lastEndFilesIndex + 1) >= _numImages;
  }

  bool _isAllAlbum() {
    return _assetsAlbumList[_lastAlbumIndex].isAll;
  }

  bool _isLastAlbum() {
    return _lastAlbumIndex + 1 >= _assetsAlbumList.length;
  }

  bool _moreImagesLeftInRange() {
    return _imageFiles.length - (_lastEndFilesIndex + 1) > 0;
  }

  @override
  Future<List<ImageFile>> getNextPhotoImages() async {
    if (_numImages == 0 || _imageFiles.isEmpty) {
      print(
          "Cannot retrieve next images before initial fetch, call fetchPhotoImages first");
    }

    while (!_enoughImageFiles()) {
      await _fetchMoreFilesFromAlbum();

      if (_isAllAlbum() || _isLastAlbum()) {
        if (_enoughImageFiles()) {
          print("got enough images from isAll/last album");
          break;
        } else {
          if (_moreImagesLeftInRange()) {
            _lastStartFilesIndex = _lastEndFilesIndex + 1;
            _lastEndFilesIndex = _imageFiles.length - 1;
            print("returning last images");
            return _imageFiles.sublist(
                _lastStartFilesIndex, _lastEndFilesIndex + 1);
          }
          print("reached end of isAll/last album, returning the same images");
          return _imageFiles.sublist(
              _lastStartFilesIndex, _lastEndFilesIndex + 1);
        }
      }

      _lastAlbumIndex++;
      _lastAlbum = _assetsAlbumList[_lastAlbumIndex];
    }

    int index = _lastEndFilesIndex + _numImages;
    if (_imageFiles.length - (_lastEndFilesIndex + 1) < _numImages) {
      print(
          "requested numImages is lower than the actual number of images, returning actual number");
      index = _imageFiles.length - 1;
    }

    _lastStartFilesIndex = _lastEndFilesIndex + 1;
    _lastEndFilesIndex = index;

    List<ImageFile> resList =
        _imageFiles.sublist(_lastStartFilesIndex, _lastEndFilesIndex + 1);

    return resList;
  }

  @override
  List<ImageFile> getPreviousPhotoImages() {
    if (_numImages == 0 || _assetsAlbumList.isEmpty) {
      print(
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

  @override
  Future<void> deleteImages(List<ImageFile> imagesFilesToDelete) async {
    List<String> imageIds = [];

    for (int i = 0; i < imagesFilesToDelete.length; i++) {
      imageIds.add(imagesFilesToDelete[i].id);
    }

    int numImagesBeforeStart = 0;
    Set imageIdsSet = imageIds.toSet();
    for (int i = 0; i <= _lastStartFilesIndex; i++) {
      if (imageIdsSet.contains(_imageFiles[i].id)) {
        numImagesBeforeStart++;
      }
    }

    _imageFiles.removeWhere((element) => imageIdsSet.contains(element.id));

    _lastStartFilesIndex -= numImagesBeforeStart;
    _lastEndFilesIndex = _lastStartFilesIndex + _numImages - 1;

    await PhotoManager.editor.deleteWithIds(imageIds);
  }

  @override
  List<ImageFile> reloadImages(int numImages) {
    _numImages = numImages;
    _lastEndFilesIndex = _lastStartFilesIndex + _numImages - 1;

    if (_lastEndFilesIndex + 1 > _imageFiles.length) {
      print(
          "requested numImages is lower than the actual number of images, returning actual number");
      _lastEndFilesIndex = _imageFiles.length - 1;
    }

    return _imageFiles.sublist(_lastStartFilesIndex, _lastEndFilesIndex + 1);
  }
}
