import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageArgs {
  final Uint8List imageBytes;
  final String heroTag;

  ImageArgs({@required this.imageBytes, this.heroTag});
}
