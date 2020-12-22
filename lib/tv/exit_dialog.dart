import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/system_methods.dart' as system;
import 'package:flutter_common/tv/key_code.dart';

class ExitDialog extends StatefulWidget {
  @override
  _ExitDialogState createState() => _ExitDialogState();
}

class _ExitDialogState extends State<ExitDialog> {
  FocusNode yes = FocusNode();
  FocusNode no = FocusNode();

  void onKey(RawKeyEvent event, FocusNode node, BuildContext context) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;

      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
          if (node == yes) {
            system.killApp();
          }
          Navigator.of(context).pop();
          break;
        case KEY_CENTER:
          if (node == yes) {
            system.killApp();
          }
          Navigator.of(context).pop();
          break;
        case KEY_RIGHT:
          if (node == no) {
            FocusScope.of(context).requestFocus(yes);
          }
          break;
        case KEY_LEFT:
          if (node == yes) {
            FocusScope.of(context).requestFocus(no);
          }
          break;
        default:
          break;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => FocusScope.of(context).requestFocus(no));
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).accentColor;

    TextStyle buttonTextStyle(FocusNode node) {
      return TextStyle(
          color: Theming.of(context)
              .onCustomColor(node.hasPrimaryFocus ? selectedColor : Theme.of(context).backgroundColor));
    }

    return AlertDialog(title: Text(_translate(TR_EXIT)), content: Text(_translate(TR_EXIT_MESSAGE)), actions: <Widget>[
      RawKeyboardListener(
          focusNode: no,
          onKey: (RawKeyEvent event) {
            onKey(event, no, context);
          },
          child: FlatButton(
              child: Text(_translate(TR_NO), style: buttonTextStyle(no)),
              color: no.hasPrimaryFocus ? selectedColor : Colors.transparent,
              onPressed: () {
                Navigator.of(context).pop();
              })),
      RawKeyboardListener(
          focusNode: yes,
          onKey: (RawKeyEvent event) {
            onKey(event, yes, context);
          },
          child: FlatButton(
              child: Text(_translate(TR_YES), style: buttonTextStyle(yes)),
              color: yes.hasPrimaryFocus ? selectedColor : Colors.transparent,
              onPressed: () {
                Navigator.of(context).pop();
                system.exitApp();
              }))
    ]);
  }

  String _translate(String key) => AppLocalizations.of(context).translate(key);
}
