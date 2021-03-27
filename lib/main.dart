import 'package:fastotvlite/app_config.dart';
import 'package:fastotvlite/main/main_common.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  await mainCommon();
  final configuredApp = AppConfig(buildType: BuildType.DEV, child: Theming(child: MyApp()));
  runApp(configuredApp);
}
