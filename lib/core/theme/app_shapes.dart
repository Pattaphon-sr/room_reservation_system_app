import 'package:flutter/material.dart';

class AppShapes {
  static const radiusXs = Radius.circular(5);
  static const radiusSm = Radius.circular(12);
  static const radiusMd = Radius.circular(16);
  static const radiusLg = Radius.circular(24);
  static const radiusXl = Radius.circular(30);
  static const radiusXxl = Radius.circular(50);

  static const roundedLg = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(radiusLg),
  );
}
