part of 'images_bloc.dart';

@immutable
abstract class ImagesEvent {}

class GetImages extends ImagesEvent {
  final int numImages;

  GetImages(this.numImages);
}
