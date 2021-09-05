import 'dart:io';

import 'package:flutter/material.dart';

class ImageArgs {
  final File imageFile;
  final String heroTag;

  ImageArgs({@required this.imageFile, this.heroTag});
}
