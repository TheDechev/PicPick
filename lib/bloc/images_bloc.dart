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
    } else {
      throw Exception(
          "Unsupported event provided to ImagesBloc: ${event.toString()}");
    }
  }

  Stream<ImagesState> _mapGetImagesToState(GetImages event) async* {
    if (state is ImagesInitial) {
      yield ImagesLoading();
      final images = await _photoRepository.fetchPhotoImages(event.numImages);
      yield ImagesLoaded(images);
    }
  }
}
