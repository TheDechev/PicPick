import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:picpick/data/models/image_file.dart';
import 'package:picpick/data/photo_repository.dart';

part 'images_event.dart';
part 'images_state.dart';

class ImagesBloc extends Bloc<ImagesEvent, ImagesState> {
  final PhotoRepository _photoRepository;

  ImagesBloc(this._photoRepository) : super(ImagesInitial());

  @override
  Stream<ImagesState> mapEventToState(
    ImagesEvent event,
  ) async* {
    if (event is GetImages) {
      yield* _mapGetImagesToState(event);
    } else if (event is NextImages) {
      yield* _mapNextImagesToState();
    } else if (event is PreviousImages) {
      yield* _mapPreviousImagesToState();
    } else if (event is ReloadImages) {
      yield* _mapReloadImagesToState(event);
    } else if (event is DeleteImages) {
      yield* _mapDeleteImagesToState(event);
    } else if (event is ResetImages) {
      yield* _mapResetImagesToState();
    } else {
      throw Exception(
          "Unsupported event provided to ImagesBloc: ${event.toString()}");
    }
  }

  Stream<ImagesState> _fetchImages(int numImages) async* {
    yield ImagesLoading();
    final images = await _photoRepository.fetchInitialPhotoImages(numImages);
    yield ImagesLoaded(images);
  }

  Stream<ImagesState> _mapGetImagesToState(GetImages event) async* {
    await _photoRepository.reset();
    yield* _fetchImages(event.numImages);
  }

  Stream<ImagesState> _mapReloadImagesToState(ReloadImages event) async* {
    yield ImagesLoading();
    final images = _photoRepository.reloadImages(event.numImages);
    yield ImagesLoaded(images);
  }

  Stream<ImagesState> _mapNextImagesToState() async* {
    yield ImagesLoading();
    final images = await _photoRepository.getNextPhotoImages();
    yield ImagesLoaded(images);
  }

  Stream<ImagesState> _mapPreviousImagesToState() async* {
    yield ImagesLoading();
    final images = _photoRepository.getPreviousPhotoImages();
    yield ImagesLoaded(images);
  }

  Stream<ImagesState> _mapDeleteImagesToState(DeleteImages event) async* {
    yield ImagesInitial();

    await _photoRepository.deleteImages(event.imageFiles);

    yield ImagesDeleted();
  }

  Stream<ImagesState> _mapResetImagesToState() async* {
    await _photoRepository.reset();
    yield ImagesInitial();
  }
}
