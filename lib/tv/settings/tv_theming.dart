import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/settings/tv_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/runtime_device.dart';
import 'package:flutter_common/tv/key_code.dart';

class ThemePickerTV extends StatefulWidget {
  final String initTheme;
  final FocusNode focus;
  final void Function() callback;

  ThemePickerTV(this.focus, this.callback, this.initTheme);

  @override
  _ThemePickerTVState createState() => _ThemePickerTVState();
}

class _ThemePickerTVState extends State<ThemePickerTV> {
  static const THEME_LIST = [TR_LIGHT, TR_DARK, TR_BLACK];

  String themeGroupValue = LIGHT_THEME_ID;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    themeGroupValue = settings.themeID();
    if (themeGroupValue == null) {
      final device = locator<RuntimeDevice>();
      if (device.hasTouch) {
        themeGroupValue = CUSTOM_LIGHT_THEME_ID;
      } else {
        themeGroupValue = LIGHT_THEME_ID;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        canRequestFocus: false,
        child: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          _dialogItem(THEME_LIST[0], LIGHT_THEME_ID),
          _dialogItem(THEME_LIST[1], DARK_THEME_ID),
          _dialogItem(THEME_LIST[2], BLACK_THEME_ID)
        ])));
  }

  Widget _dialogItem(String text, String themeId) {
    return Focus(
        onKey: _listControl,
        focusNode: widget.focus,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: borderColor(context, themeId == themeGroupValue && widget.focus.hasPrimaryFocus), width: 2)),
            child: RadioListTile<String>(
                activeColor: Theme.of(context).accentColor,
                title: Text(AppLocalizations.of(context).translate(text), style: TextStyle(fontSize: 20)),
                value: themeId,
                groupValue: themeGroupValue,
                onChanged: Theming.of(context).setTheme)));
  }

  bool _listControl(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_UP:
          _up();
          break;
        case KEY_DOWN:
          _down();
          break;
        case KEY_LEFT:
          widget.callback();
          break;
        default:
      }
    }
    return widget.focus.hasPrimaryFocus;
  }

  void _down() {
    if (themeGroupValue == LIGHT_THEME_ID) {
      themeGroupValue = DARK_THEME_ID;
    } else if (themeGroupValue == DARK_THEME_ID) {
      themeGroupValue = BLACK_THEME_ID;
    } else if (themeGroupValue == BLACK_THEME_ID) {
      themeGroupValue = LIGHT_THEME_ID;
    }
    Theming.of(context).setTheme(themeGroupValue);
  }

  void _up() {
    if (themeGroupValue == LIGHT_THEME_ID) {
      themeGroupValue = BLACK_THEME_ID;
    } else if (themeGroupValue == DARK_THEME_ID) {
      themeGroupValue = LIGHT_THEME_ID;
    } else if (themeGroupValue == BLACK_THEME_ID) {
      themeGroupValue = DARK_THEME_ID;
    }
    Theming.of(context).setTheme(themeGroupValue);
  }
}
