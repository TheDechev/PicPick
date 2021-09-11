import 'package:flutter/material.dart';

final kBadgeColor = Colors.pink[200];

const kNoImageAsset = 'images/no_image.png';

final kImageHeroTag = 'imageHero';

const int kDefaultNumImagesToShow = 4;

const kRoundedShape =
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18)));

const kRoundedBoxDecoration = BoxDecoration(
  color: Colors.pinkAccent,
  borderRadius: BorderRadius.all(Radius.circular(18)),
);

const kBodyTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w400,
);
const kHeaderTextStyle =
    TextStyle(color: Colors.white, fontWeight: FontWeight.w700, shadows: [
  Shadow(
    color: Colors.black,
    offset: Offset(0, 2),
  ),
]);
