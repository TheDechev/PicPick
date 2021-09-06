import 'dart:io';

import 'package:equatable/equatable.dart';

class ImageFile extends Equatable {
  final String id;
  final File file;

  ImageFile(this.id, this.file);

  @override
  List<Object> get props => [id, file];
}
