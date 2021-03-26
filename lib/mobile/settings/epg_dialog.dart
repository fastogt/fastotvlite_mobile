import 'package:fastotvlite/constants.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/settings/settings_page.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class EpgSettingsTile extends StatefulWidget {
  const EpgSettingsTile();

  @override
  _EpgSettingsTileState createState() => _EpgSettingsTileState();
}

class _EpgSettingsTileState extends State<EpgSettingsTile> {
  String _epgUrl = '';

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _epgUrl = settings.epgLink();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const SettingsIcon(Icons.add_to_queue),
        title: Text(AppLocalizations.of(context).translate(TR_EPG_PROVIDER)),
        subtitle: Text(_epgUrl),
        onTap: () => _onTap());
  }

  void _onTap() async {
    final settings = locator<LocalStorageService>();
    await showDialog(
      context: context,
      builder: (BuildContext context) => EpgDialog(_epgUrl),
    ).then((value) {
      if (value != null) {
        setState(() => _epgUrl = value);
        settings.setEpgLink(_epgUrl);
      }
    });
  }
}

class EpgDialog extends StatefulWidget {
  final String link;

  const EpgDialog(this.link);

  @override
  _EpgDialogState createState() => _EpgDialogState();
}

class _EpgDialogState extends State<EpgDialog> {
  String _epgLink = EPG_URL;
  String password = '';
  final TextEditingController _textEditingController = TextEditingController();
  final reg = RegExp('^http([s]{0,1})://([!-~]+)/');
  bool validator = true;
  int groupValue = 0;
  FocusNode textFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _epgLink = settings.epgLink();
    _textEditingController.text = _epgLink;
    setGroupValue();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  String _errorText() {
    if (validator) {
      return null;
    }

    final String _text = _textEditingController.text;
    if (_text.isEmpty) {
      return _translate(TR_ERROR_FORM);
    } else if (!reg.hasMatch(_text) || _text.substring(_text.length - 1) != '/') {
      return _translate(TR_INCORRECT_LINK);
    }
    return null;
  }

  void _validate() {
    final String _text = _textEditingController.text;
    setState(() {
      validator =
          _text.isNotEmpty && reg.hasMatch(_text) && _text.substring(_text.length - 1) == '/';
      setGroupValue();
    });
  }

  void setGroupValue() {
    if (_textEditingController.text != EPG_URL) {
      groupValue = 1;
    } else {
      groupValue = 0;
    }
  }

  Widget listTile(String title, int value) {
    return RadioListTile(
        activeColor: Theme.of(context).accentColor,
        value: value,
        groupValue: groupValue,
        onChanged: (int value) {
          setState(() {
            groupValue = value;
          });
          if (groupValue == 1) {
            textFieldFocus.requestFocus();
          } else {
            if (textFieldFocus.hasPrimaryFocus) {
              FocusScope.of(context).unfocus();
            }
            _textEditingController.text = EPG_URL;
          }
        },
        title: Text(title));
  }

  Widget _content() {
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          listTile('FastoTV', 0),
          listTile(_translate(TR_EPG_CUSTOM), 1),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                  focusNode: textFieldFocus,
                  controller: _textEditingController,
                  onChanged: (String text) => _validate(),
                  onFieldSubmitted: (String text) => _validate(),
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).accentColor,
                      focusColor: Theme.of(context).accentColor,
                      labelText: _translate(TR_EPG_URL),
                      errorText: _errorText())))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(_translate(TR_EPG_PROVIDER)),
        content: _content(),
        contentPadding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
        actions: <Widget>[
          Opacity(
              opacity: BUTTON_OPACITY,
              child: FlatButton(
                  textColor: Theming.of(context).onBrightness(),
                  child: Text(_translate(TR_CANCEL), style: const TextStyle(fontSize: 14)),
                  onPressed: () => Navigator.of(context).pop())),
          FlatButton(
              textColor: Theme.of(context).accentColor,
              child: Text(_translate(TR_SUBMIT), style: const TextStyle(fontSize: 14)),
              onPressed: () {
                _validate();
                if (validator) {
                  Navigator.of(context).pop(_textEditingController.text);
                }
              })
        ]);
  }

  String _translate(String key) => AppLocalizations.of(context).translate(key);
}
