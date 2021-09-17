import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ImageFile extends Equatable {
  final String id;
  final Uint8List fullImageBytes;
  final Uint8List thumbnailBytes;

  ImageFile(
      {@required this.id,
      @required this.thumbnailBytes,
      @required this.fullImageBytes});

  @override
  List<Object> get props => [id, fullImageBytes, thumbnailBytes];
}
