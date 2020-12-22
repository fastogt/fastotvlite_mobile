import 'dart:core';

import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';

class ThemePicker extends StatefulWidget {
  const ThemePicker();

  _ThemePickerState createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  String themeGroupValue = LIGHT_THEME_ID;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    themeGroupValue = settings.themeID();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.color_lens, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_GENERAL_THEME)),
        subtitle: Text(_themeName(themeGroupValue)),
        onTap: showThemeDialog);
  }

  Widget _dialogItem(String themeId) {
    return RadioListTile<String>(
        activeColor: Theme.of(context).accentColor,
        value: themeId,
        groupValue: themeGroupValue,
        title: Text(translate(context, _themeName(themeId))),
        onChanged: handleTheme);
  }

  void showThemeDialog() async {
    SimpleDialog dialog = SimpleDialog(
        contentPadding: EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 0.0),
        title: Text(translate(context, TR_CHOOSE_THEME)),
        children: <Widget>[
          _dialogItem(LIGHT_THEME_ID),
          _dialogItem(DARK_THEME_ID),
          _dialogItem(CUSTOM_LIGHT_THEME_ID),
          _dialogItem(CUSTOM_DARK_THEME_ID)
        ]);

    final id = await showDialog(context: context, builder: (BuildContext context) => dialog);
    if (id != null) Theming.of(context).setTheme(id);
  }

  String _themeName(String id) {
    switch (id) {
      case LIGHT_THEME_ID:
        return TR_LIGHT;
      case DARK_THEME_ID:
        return TR_DARK;
      case CUSTOM_LIGHT_THEME_ID:
        return TR_COLORED_LIGHT;
      case CUSTOM_DARK_THEME_ID:
        return TR_COLORED_DARK;
      default:
        return TR_LIGHT;
    }
  }

  void handleTheme(String id) {
    setState(() {
      themeGroupValue = id;
    });
    Navigator.of(context).pop(id);
  }
}
