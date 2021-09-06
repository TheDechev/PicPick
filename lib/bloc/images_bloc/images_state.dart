part of 'images_bloc.dart';

@immutable
abstract class ImagesState {}

class ImagesInitial extends ImagesState {}

class ImagesLoading extends ImagesState {}

class ImagesLoaded extends ImagesState with EquatableMixin {
  final List<ImageFile> imageFiles;

  ImagesLoaded(this.imageFiles);

  @override
  List<Object> get props => [imageFiles];
}

class ImagesDeleted extends ImagesState {}

class ImagesError extends ImagesState with EquatableMixin {
  final String message;

  ImagesError(this.message);

  @override
  List<Object> get props => [message];
}
