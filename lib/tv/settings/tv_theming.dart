import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class ThemePickerTV extends StatefulWidget {
  final String initTheme;

  const ThemePickerTV(this.initTheme);

  @override
  _ThemePickerTVState createState() {
    return _ThemePickerTVState();
  }
}

class _ThemePickerTVState extends State<ThemePickerTV> {
  static const THEME_LIST = [TR_LIGHT, TR_DARK, TR_BLACK];

  String themeGroupValue = LIGHT_THEME_ID;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    themeGroupValue = settings.themeID() ?? LIGHT_THEME_ID;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        canRequestFocus: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          _dialogItem(THEME_LIST[0], LIGHT_THEME_ID),
          _dialogItem(THEME_LIST[1], DARK_THEME_ID),
          _dialogItem(THEME_LIST[2], BLACK_THEME_ID)
        ]));
  }

  Widget _dialogItem(String text, String themeId) {
    return RadioListTile<String>(
        activeColor: Theme.of(context).colorScheme.secondary,
        title: Text(AppLocalizations.of(context).translate(text),
            style: const TextStyle(fontSize: 20)),
        value: themeId,
        groupValue: themeGroupValue,
        onChanged: Theming.of(context).setTheme);
  }
}
