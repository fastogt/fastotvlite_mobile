import 'dart:math';

import 'package:flutter/material.dart';

class VodFavoriteButton extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;

  VodFavoriteButton({@required this.child, this.height, this.width});

  static const HEIGHT = 36.0;

  @override
  Widget build(BuildContext context) {
    final _height = height ?? HEIGHT;
    final _width = width ?? HEIGHT;
    return Positioned(
        right: 5,
        top: 5,
        child: Container(
            decoration: new BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: new BorderRadius.all(Radius.circular(min(_width, _height) / 2))),
            height: _height,
            width: _width,
            child: child));
  }
}
