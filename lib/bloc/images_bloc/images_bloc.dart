import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
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
    } else if (event is ReloadImages) {
      yield* _mapReloadImagesToState(event);
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
    yield* _fetchImages(event.numImages);
  }

  Stream<ImagesState> _mapReloadImagesToState(ReloadImages event) async* {
    yield* _fetchImages(event.numImages);
  }

  Stream<ImagesState> _mapNextImagesToState() async* {
    yield ImagesLoading();
    final images = await _photoRepository.fetchNextPhotoImages();
    yield ImagesLoaded(images);
  }
}
