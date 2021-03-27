import 'package:flutter/material.dart';

enum BuildType { DEV, PROD }

class AppConfig extends InheritedWidget {
  const AppConfig({this.buildType, Widget child}) : super(child: child);

  final BuildType buildType;

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
