import 'dart:async';

import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/tv/settings/tv_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/tv/key_code.dart';

class PaddingSettings extends StatefulWidget {
  final FocusNode focus;
  final void Function() callback;
  final StreamController controller;

  PaddingSettings(this.focus, this.callback, this.controller);

  @override
  _PaddingSettingsState createState() => _PaddingSettingsState();
}

class _PaddingSettingsState extends State<PaddingSettings> {
  double percent;
  TextStyle textStyle = TextStyle(fontSize: 32);
  TextStyle symbolsStyle;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    percent = settings.screenScale();
  }

  @override
  Widget build(BuildContext context) {
    symbolsStyle = TextStyle(fontSize: 32, color: borderColor(context, widget.focus.hasPrimaryFocus));
    return Focus(
        focusNode: widget.focus,
        onKey: _listControl,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(padding: const EdgeInsets.all(8.0), child: Text('+', style: symbolsStyle)),
          Container(child: Center(child: Text((percent * 100).toStringAsFixed(1) + '%', style: textStyle))),
          Padding(padding: const EdgeInsets.all(8.0), child: Text('-', style: symbolsStyle))
        ]));
  }

  bool _listControl(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_DOWN:
          if (percent > 0.9) {
            percent -= 0.001;
            widget.controller.add(percent);
          }
          break;
        case KEY_UP:
          if (percent < 1) {
            percent += 0.001;
            widget.controller.add(percent);
          }
          break;
        case KEY_LEFT:
          final settings = locator<LocalStorageService>();
          settings.setscreenScale(percent);
          widget.callback();
          break;
        default:
      }
    }
    return widget.focus.hasPrimaryFocus;
  }
}
