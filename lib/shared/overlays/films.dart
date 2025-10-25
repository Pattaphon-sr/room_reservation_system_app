import 'dart:ui';
import 'package:flutter/material.dart';

Widget colorFilm(Color color, [double opacity = 0.2]) =>
    ColoredBox(color: color.withOpacity(opacity));

Widget gradientFilm(Gradient g) =>
    DecoratedBox(decoration: BoxDecoration(gradient: g));

Widget blurFilm({double sigma = 8, Color tint = const Color(0x26FFFFFF)}) =>
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: ColoredBox(color: tint),
    );

Widget blendFilm(Color color, BlendMode mode) => ColorFiltered(
  colorFilter: ColorFilter.mode(color, mode),
  child: const SizedBox.expand(),
);

Widget gradientBlendFilm(Gradient gradient, BlendMode mode) => ShaderMask(
  shaderCallback: (rect) => gradient.createShader(rect),
  blendMode: mode,
  child: const SizedBox.expand(),
);
