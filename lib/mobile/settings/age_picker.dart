import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/settings/settings_page.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/theming.dart';
import 'package:numberpicker/numberpicker.dart';

class AgeSettingsTile extends StatefulWidget {
  @override
  _AgeSettingsTileState createState() => _AgeSettingsTileState();
}

class _AgeSettingsTileState extends State<AgeSettingsTile> {
  int ageRating = IARC_DEFAULT_AGE;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    ageRating = settings.ageRating();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: SettingsIcon(Icons.child_care),
        title: Text(AppLocalizations.of(context).translate(TR_PARENTAL_CONTROL)),
        subtitle: Text(AppLocalizations.of(context).translate(TR_AGE_RESTRICTION)),
        onTap: () => _onTap(),
        trailing:
            Padding(padding: const EdgeInsets.all(8.0), child: Text('$ageRating', style: TextStyle(fontSize: 16))));
  }

  void _onTap() async {
    final settings = locator<LocalStorageService>();
    await showDialog(
      context: context,
      builder: (BuildContext context) => AgeSelector(ageRating),
    ).then((value) {
      if (value != null) {
        setState(() => ageRating = value);
        settings.setAgeRating(ageRating);
      }
    });
  }
}

class AgeSelector extends StatefulWidget {
  final int age;

  const AgeSelector(this.age);

  @override
  _AgeSelectorState createState() => _AgeSelectorState();
}

class _AgeSelectorState extends State<AgeSelector> {
  int age = IARC_DEFAULT_AGE;
  String password = '';
  static const ITEM_HEIGHT = 48.0;
  TextEditingController passwordController = TextEditingController();
  bool authorized = false;
  bool validatePassword = true;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    age = settings.ageRating();

    // TODO нет данных аккаунта, надо сделать пароль и его хранить
    //password = settings.password();
    passwordController.text = '';
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  String _translate(String key) => AppLocalizations.of(context).translate(key);

  String _errorText() {
    if (validatePassword) {
      return null;
    }

    if (passwordController.text.isEmpty) {
      return _translate(TR_ERROR_FORM);
    } else if (passwordController.text != password) {
      return _translate(TR_INCORRECT_PASSWORD);
    }
    return null;
  }

  bool _validate() {
    return passwordController.text.isNotEmpty && password == passwordController.text;
  }

  Widget _passwordField() {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      TextFormField(
          controller: passwordController,
          obscureText: true,
          onChanged: (String text) {
            validatePassword = _validate();
          },
          onFieldSubmitted: (term) {
            validatePassword = _validate();
          },
          decoration: InputDecoration(
              fillColor: Colors.amber,
              focusColor: Colors.amber,
              labelStyle: new TextStyle(color: const Color(0xFF424242)),
              hintText: _translate(TR_PASSWORD),
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              errorText: _errorText()))
    ]);
  }

  Widget _picker() {
    return Stack(fit: StackFit.loose, children: <Widget>[
      Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        NumberPicker.integer(
            itemExtent: ITEM_HEIGHT,
            initialValue: age,
            minValue: 0,
            maxValue: IARC_DEFAULT_AGE,
            onChanged: (value) {
              setState(() {
                age = value;
              });
            })
      ]),
      Container(
          height: ITEM_HEIGHT * 3,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[Spacer(), Divider(), Spacer(), Divider(), Spacer()]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(_translate(!authorized ? TR_PARENTAL_CONTROL : TR_AGE_RESTRICTION)),
        content: SingleChildScrollView(child: !authorized ? _passwordField() : _picker()),
        contentPadding: EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
        actions: <Widget>[
          Opacity(
              opacity: BUTTON_OPACITY,
              child: FlatButton(
                  textColor: Theming.of(context).onBrightness(),
                  child: Text(_translate(TR_CANCEL), style: TextStyle(fontSize: 14)),
                  onPressed: () => Navigator.of(context).pop(widget.age))),
          FlatButton(
              textColor: Theme.of(context).accentColor,
              child: Text(_translate(!authorized ? TR_PROCEED : TR_SUBMIT), style: TextStyle(fontSize: 14)),
              onPressed: () {
                if (!authorized) {
                  setState(() {
                    validatePassword = _validate();
                  });
                  if (validatePassword) {
                    setState(() {
                      authorized = true;
                    });
                  }
                } else {
                  Navigator.of(context).pop(age.toInt());
                }
              })
        ]);
  }
}
