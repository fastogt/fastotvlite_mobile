import 'dart:core';

import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/theming.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker.primary() : color = 0;

  const ColorPicker.accent() : color = 1;

  final int color;

  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    if (widget.color == 0) {
      return _primary();
    } else if (widget.color == 1) {
      return _accent();
    }
    return SizedBox();
  }

  Widget _primary() {
    return ListTile(
        leading: Icon(Icons.format_color_fill, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_PRIMARY_COLOR)),
        subtitle: Text(Theme.of(context).primaryColor.toString()),
        onTap: () async {
          final id = Theming.of(context).themeId;
          if (id == CUSTOM_LIGHT_THEME_ID || id == CUSTOM_DARK_THEME_ID) {
            final _color = await _openColorPicker();
            if (_color != null) {
              Theming.of(context).setPrimaryColor(_color);
            }
          }
        },
        trailing: _colorCircle(Theme.of(context).primaryColor));
  }

  Widget _accent() {
    return ListTile(
        leading: Icon(Icons.colorize, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_ACCENT_COLOR)),
        subtitle: Text(Theme.of(context).accentColor.toString()),
        onTap: () async {
          final id = Theming.of(context).themeId;
          if (id == CUSTOM_LIGHT_THEME_ID || id == CUSTOM_DARK_THEME_ID) {
            final _color = await _openColorPicker();
            if (_color != null) {
              Theming.of(context).setAccentColor(_color);
            }
          }
        },
        trailing: _colorCircle(Theme.of(context).accentColor));
  }

  Widget _colorCircle(Color color) {
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color, border: Border.all(color: Theming.of(context).onPrimary())));
  }

  Future<Color> _openColorPicker() async {
    return showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
            title: translate(context, widget.color == 0 ? TR_PRIMARY_COLOR : TR_ACCENT_COLOR),
            initColor: widget.color == 0 ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
            cancel: translate(context, TR_CANCEL),
            submit: translate(context, TR_SUBMIT)));
  }
}
