import 'package:fastotvlite/base/login/textfields.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/settings/tv_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/tv/key_code.dart';

class AgePickerTV extends StatefulWidget {
  final FocusNode focus;
  final void Function() callback;

  AgePickerTV(this.focus, this.callback);

  @override
  _AgePickerTVState createState() => _AgePickerTVState();
}

class _AgePickerTVState extends State<AgePickerTV> {
  int currentFocus = 0;

  final divider = Divider(height: 0.0);

  int ageRating = IARC_DEFAULT_AGE;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    ageRating = settings.ageRating();
  }

  bool _listControl(FocusNode node, RawKeyEvent event) {
    final settings = locator<LocalStorageService>();
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_UP:
          settings.setAgeRating(ageRating);
          currentFocus = 0;
          break;
        case KEY_DOWN:
          currentFocus = 1;
          break;
        case KEY_LEFT:
          if (currentFocus != 1) {
            widget.callback();
          } else {
            if (ageRating > 0) {
              ageRating--;
              settings.setAgeRating(ageRating);
            }
          }
          break;
        case KEY_RIGHT:
          if (currentFocus == 1) {
            if (ageRating < MAX_IARC_AGE) {
              ageRating++;
              settings.setAgeRating(ageRating);
            }
          }
          break;
        default:
      }
      setState(() {});
    }
    return widget.focus.hasPrimaryFocus;
  }

  Widget ageWidget() {
    return ListTile(
        leading: Icon(Icons.child_care, color: Theming.of(context).onBrightness()),
        title: Text(AppLocalizations.of(context).translate(TR_AGE_RESTRICTION),
            softWrap: true, style: TextStyle(fontSize: 20)));
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        onKey: _listControl,
        focusNode: widget.focus,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: borderColor(context, 0 == currentFocus && widget.focus.hasPrimaryFocus), width: 2)),
              child: ageWidget()),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: borderColor(context, 1 == currentFocus && widget.focus.hasPrimaryFocus), width: 2)),
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Icon(Icons.arrow_left),
                Text('$ageRating', style: TextStyle(fontSize: 24)),
                Icon(Icons.arrow_right)
              ]))
        ]));
  }
}

class AgePickerPassword extends StatefulWidget {
  @override
  _AgePickerPasswordState createState() => _AgePickerPasswordState();
}

class _AgePickerPasswordState extends State<AgePickerPassword> {
  FocusNode backButtonNode = FocusNode();
  final TextFieldNode passwordNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final passwordController = TextEditingController();
  bool validatePassword = true;
  String password = '';

  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    //TODO см. пункт про пароль на мобилке
    //password = settings.password();
    passwordController.text = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(passwordNode.main);
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Widget backButton() {
    Color buttonColor(FocusNode node) {
      return node.hasPrimaryFocus ? Theme.of(context).accentColor : Theming.of(context).onPrimary();
    }

    return Stack(children: <Widget>[
      Focus(
          focusNode: backButtonNode,
          onKey: onBack,
          child: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 32,
              color: buttonColor(backButtonNode),
              onPressed: () {
                Navigator.of(context).pop(false);
              }))
    ]);
  }

  Widget passwordField() {
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

    return LoginTextField(
      mainFocus: passwordNode.main,
      textFocus: passwordNode.text,
      textEditingController: passwordController,
      validate: validatePassword,
      errorText: _errorText(),
      hintText: _translate(TR_PASSWORD),
      onFieldSubmit: () {
        validatePassword = passwordController.text.isNotEmpty && password == passwordController.text;
        if (validatePassword) {
          Navigator.of(context).pop(true);
        } else {
          FocusScope.of(context).requestFocus(passwordNode.main);
        }
      },
      onKey: nodeAction,
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
                style: TextStyle(color: Theming.of(context).onCustomColor(Theme.of(context).primaryColor))),
            centerTitle: true),
        body: Center(
            child: Container(
                height: query.size.height,
                width: sideFieldsWidth,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(AppLocalizations.of(context).translate(TR_AGE_RESTRICTION_PASSWORD),
                              softWrap: true, style: TextStyle(fontSize: 24))),
                      passwordField()
                    ]))));
  }

  bool onBack(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          Navigator.of(context).pop(false);
          break;
        case KEY_RIGHT:
          FocusScope.of(context).requestFocus(passwordNode.main);
          break;
        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool nodeAction(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          FocusScope.of(context).requestFocus(passwordNode.text);
          break;
        case KEY_LEFT:
          FocusScope.of(context).requestFocus(backButtonNode);
          break;
        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  String _translate(String key) => AppLocalizations.of(context).translate(key);
}
