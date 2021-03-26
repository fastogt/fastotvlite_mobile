import 'package:fastotvlite/localization/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';

class ExitDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(translate(context, TR_EXIT)),
        content: Text(translate(context, TR_EXIT_MESSAGE)),
        actions: <Widget>[
          TextButtonEx(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: translate(context, TR_NO)),
          TextButtonEx(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              text: translate(context, TR_YES))
        ]);
  }
}
