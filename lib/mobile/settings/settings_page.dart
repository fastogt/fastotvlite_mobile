import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/settings/age_picker.dart';
import 'package:fastotvlite/mobile/settings/epg_dialog.dart';
import 'package:fastotvlite/pages/debug_page.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/color_picker.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/theme/theme_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();
  
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextStyle mainTextStyle = TextStyle(fontSize: 16);

  @override
  void initState() {
    super.initState();
    onlyPortrait();
  }

  @override
  void dispose() {
    super.dispose();
    allowAll();
  }

  @override
  Widget build(BuildContext context) {
    final divider = Divider(height: 0.0);
    final color = Theming.of(context).onPrimary();
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: color),
            title: Text(_translate(TR_SETTINGS), style: TextStyle(color: color))),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          ListHeader(text: _translate(TR_PLAYER)),
          _LastViewed(),
          _Controls.sound(),
          _Controls.brightness(),
          divider,
          ListHeader(text: _translate(TR_CONTENT_SETTINGS)),
          AgeSettingsTile(),
          EpgSettingsTile(),
          divider,
          ListHeader(text: _translate(TR_THEME)),
          ThemePicker(),
          ColorPicker.primary(),
          ColorPicker.accent(),
          divider,
          ListHeader(text: _translate(TR_LOCALIZATION)),
          LanguagePicker.settings((locale) {
            final settings = locator<LocalStorageService>();
            settings.setLangCode(locale.languageCode);
            settings.setCountryCode(locale.countryCode);
          }),
          divider,
          ListHeader(text: _translate(TR_ABOUT)),
          VersionTile.settings()
        ])));
  }

  String _translate(String key) => AppLocalizations.of(context).translate(key);
}

class SettingsIcon extends StatelessWidget {
  final IconData icon;

  SettingsIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Theming.of(context).onBrightness());
  }
}

class _LastViewed extends StatefulWidget {
  @override
  _LastViewedState createState() => _LastViewedState();
}

class _LastViewedState extends State<_LastViewed> {
  bool _saveLastViewed = false;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _saveLastViewed = settings.saveLastViewed();
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
        leading: SettingsIcon(_saveLastViewed ? Icons.bookmark : Icons.bookmark_border),
        title: Text(_translate(TR_LAST_VIEWED)),
        subtitle: Text(_translate(TR_LAST_VIEWED_SUB)),
        onTap: () => setLastViewed(!_saveLastViewed),
        trailing: Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _saveLastViewed,
            onChanged: (bool value) => setLastViewed(value)));
  }

  void setLastViewed(bool value) {
    setState(() {
      _saveLastViewed = value;
      final settings = locator<LocalStorageService>();
      settings.setSaveLastViewed(value);
      if (_saveLastViewed == false) {
        settings.setLastChannel(null);
      }
    });
  }

  String _translate(String key) => AppLocalizations.of(context).translate(key);
}

class _Controls extends StatefulWidget {
  final int type;

  _Controls.sound() : type = 0;

  _Controls.brightness() : type = 1;

  @override
  _ControlsState createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  bool _value = true;
  bool _isSound;

  @override
  void initState() {
    super.initState();
    _isSound = widget.type == 0;
    final settings = locator<LocalStorageService>();
    _value = widget.type == 0 ? settings.soundChange() : settings.brightnessChange();
  }

  @override
  Widget build(BuildContext context) => _tile(_isSound);

  Widget _tile(bool sound) {
    return ListTile(
        leading: SettingsIcon(sound ? Icons.volume_up : Icons.brightness_7),
        title: Text(_translate(sound ? TR_SOUND_CONTROL : TR_BRIGHTNESS_CONTROL)),
        subtitle: Text(_translate(_value ? TR_ABSOLUTE : TR_RELATIVE)),
        onTap: () => _onTap());
  }

  void _onTap() {
    setState(() {
      final settings = locator<LocalStorageService>();
      _value = !_value;
      _isSound ? settings.setSoundChange(_value) : settings.setBrightnessChange(_value);
    });
  }

  String _translate(String key) => AppLocalizations.of(context).translate(key);
}
