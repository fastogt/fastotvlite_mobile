import 'package:flutter/material.dart';

enum BuildType { DEV, PROD }

class AppConfig extends InheritedWidget {
  const AppConfig({required this.buildType, required Widget child}) : super(child: child);

  final BuildType buildType;

  static AppConfig of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
