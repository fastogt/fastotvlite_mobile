import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/player/appbar_player.dart';
import 'package:flutter_fastotv_common/player/side_appbar_player.dart';

const double INTERFACE_OPACITY = 0.5;

abstract class AppBarPlayerLive<T extends StatefulWidget> extends SideAppBarPlayer<T> {
  bool brightnessChange() {
    final settings = locator<LocalStorageService>();
    return settings.brightnessChange();
  }

  bool soundChange() {
    final settings = locator<LocalStorageService>();
    return settings.soundChange();
  }
}

abstract class AppBarPlayerVod<T extends StatefulWidget> extends AppBarPlayer<T> {
  bool brightnessChange() {
    final settings = locator<LocalStorageService>();
    return settings.brightnessChange();
  }

  bool soundChange() {
    final settings = locator<LocalStorageService>();
    return settings.soundChange();
  }

  Color get backgroundColor => Colors.black;

  Color get overlaysTextColor => Colors.white;
}
