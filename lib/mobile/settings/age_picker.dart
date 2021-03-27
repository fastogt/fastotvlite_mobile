import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/settings/settings_page.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:numberpicker/numberpicker.dart';

class AgeSettingsTile extends StatefulWidget {
  const AgeSettingsTile();

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
        leading: const SettingsIcon(Icons.child_care),
        title: Text(AppLocalizations.of(context).translate(TR_PARENTAL_CONTROL)),
        subtitle: Text(AppLocalizations.of(context).translate(TR_AGE_RESTRICTION)),
        onTap: () => _onTap(),
        trailing: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$ageRating', style: const TextStyle(fontSize: 16))));
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
  String password;
  static const ITEM_HEIGHT = 48.0;
  TextEditingController passwordController = TextEditingController();
  bool authorized = false;
  bool validatePassword = true;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    age = settings.ageRating();
    password = '';
    passwordController.text = '';
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  String _translate(String key) {
    return AppLocalizations.of(context).translate(key) ?? '';
  }

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
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
                  labelStyle: const TextStyle(color: Color(0xFF424242)),
                  hintText: _translate(TR_PASSWORD),
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  errorText: _errorText()))
        ]);
  }

  Widget _picker() {
    return Stack(children: <Widget>[
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            NumberPicker(
                itemHeight: ITEM_HEIGHT,
                value: age,
                minValue: 0,
                maxValue: IARC_DEFAULT_AGE,
                onChanged: (value) {
                  setState(() {
                    age = value;
                  });
                })
          ]),
      SizedBox(
          height: ITEM_HEIGHT * 3,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const <Widget>[Spacer(), Divider(), Spacer(), Divider(), Spacer()]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(!authorized ? _translate(TR_PARENTAL_CONTROL) : _translate(TR_AGE_RESTRICTION)),
        content: !authorized ? _passwordField() : _picker(),
        contentPadding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
        actions: <Widget>[
          TextButtonEx(
              onPressed: () {
                Navigator.of(context).pop(widget.age);
              },
              text: translate(context, TR_CANCEL)),
          TextButtonEx(
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
              },
              text: translate(context, !authorized ? TR_PROCEED : TR_SUBMIT))
        ]);
  }
}
