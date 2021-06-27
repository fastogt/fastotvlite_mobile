import 'package:fastotvlite/base/login/textfields.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';

class AgePickerTV extends StatefulWidget {
  const AgePickerTV();

  @override
  _AgePickerTVState createState() {
    return _AgePickerTVState();
  }
}

class _AgePickerTVState extends State<AgePickerTV> {
  final divider = const Divider(height: 0.0);
  int ageRating = IARC_DEFAULT_AGE;
  bool passed = false;
  final FocusNode _pickerNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    ageRating = settings.ageRating();
  }

  KeyEventResult _listControl(FocusNode node, RawKeyEvent event) {
    final settings = locator<LocalStorageService>();
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KEY_UP:
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          setState(() {});
          return KeyEventResult.handled;
        case KEY_LEFT:
          if (ageRating > 0) {
            ageRating--;
            settings.setAgeRating(ageRating);
          }
          setState(() {});
          return KeyEventResult.handled;
        case KEY_RIGHT:
          if (ageRating < MAX_IARC_AGE) {
            ageRating++;
            settings.setAgeRating(ageRating);
          }
          setState(() {});
          return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }

  Widget ageWidget() {
    return ListTile(
        onTap: () {
          if (!passed) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return AgePickerPassword();
            })).then((value) {
              passed = value ?? false;
              if (passed) {
                FocusScope.of(context).requestFocus(_pickerNode);
              }
              setState(() {});
            });
          }
        },
        leading: Icon(Icons.child_care, color: Theming.of(context).onBrightness()),
        title: Text(AppLocalizations.of(context).translate(TR_AGE_RESTRICTION),
            softWrap: true, style: const TextStyle(fontSize: 20)));
  }

  @override
  Widget build(BuildContext context) {
    final color = _pickerNode.hasPrimaryFocus ? Theme.of(context).accentColor : null;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      ageWidget(),
      Focus(
          focusNode: _pickerNode,
          skipTraversal: !passed,
          onKey: _listControl,
          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Icon(Icons.arrow_left, color: color),
            Text('$ageRating', style: const TextStyle(fontSize: 24)),
            Icon(Icons.arrow_right, color: color)
          ]))
    ]);
  }
}

class AgePickerPassword extends StatefulWidget {
  @override
  _AgePickerPasswordState createState() => _AgePickerPasswordState();
}

class _AgePickerPasswordState extends State<AgePickerPassword> {
  final TextFieldNode passwordNode =
      TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final passwordController = TextEditingController();
  String password;

  @override
  void initState() {
    super.initState();
    password = '';
    passwordController.text = '';
  }

  String _translate(String key) {
    return AppLocalizations.of(context).translate(key);
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Widget backButton() {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 32,
        onPressed: () {
          Navigator.of(context).pop(false);
        });
  }

  Widget passwordField() {
    return LoginTextField(
      mainFocus: passwordNode.main,
      textFocus: passwordNode.text,
      controller: passwordController,
      hintText: _translate(TR_PASSWORD),
      validator: (text) {
        if (text.isEmpty) {
          return _translate(TR_ERROR_FORM);
        } else if (passwordController.text != password) {
          return _translate(TR_INCORRECT_PASSWORD);
        }
        return null;
      },
      onFieldSubmit: (text) {
        final validatePassword = text.isNotEmpty && password == text;
        if (validatePassword) {
          Navigator.of(context).pop(true);
        } else {
          FocusScope.of(context).requestFocus(passwordNode.main);
        }
      },
      obscureText: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final categoriesWidth = query.size.width / 4;
    final sideFieldsWidth = (query.size.width - categoriesWidth) / 2;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
            leading: backButton(),
            elevation: 0,
            title: Text(_translate(TR_PARENTAL_CONTROL),
                style: TextStyle(color: Theming.onCustomColor(Theme.of(context).primaryColor))),
            centerTitle: true),
        body: Center(
            child: SizedBox(
                height: query.size.height,
                width: sideFieldsWidth,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                          "Input your account's password to access parental control settings.",
                          softWrap: true,
                          style: TextStyle(fontSize: 24))),
                  passwordField()
                ]))));
  }

  KeyEventResult onBack(FocusNode node, RawKeyEvent event) {
    return onKeyArrows(context, event, onEnter: () {
      Navigator.of(context).pop(false);
    }, onBack: () {
      Navigator.of(context).pop(false);
    });
  }
}
