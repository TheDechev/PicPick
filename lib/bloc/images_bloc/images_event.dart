part of 'images_bloc.dart';

@immutable
abstract class ImagesEvent {}

class GetImages extends ImagesEvent with EquatableMixin {
  final int numImages;

  GetImages(this.numImages);

  @override
  List<Object> get props => [numImages];
}

class ReloadImages extends ImagesEvent with EquatableMixin {
  final int numImages;

  ReloadImages(this.numImages);

  @override
  List<Object> get props => [numImages];
}

class NextImages extends ImagesEvent {}

class PreviousImages extends ImagesEvent {}

class DeleteImages extends ImagesEvent with EquatableMixin {
  final List<ImageFile> imageFiles;

  DeleteImages(this.imageFiles);

  @override
  List<Object> get props => imageFiles;
}

class ResetImages extends ImagesEvent {}
