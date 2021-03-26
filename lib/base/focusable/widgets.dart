import 'package:fastotvlite/base/focusable/wrap.dart';
import 'package:fastotvlite/base/login/textfields.dart';
import 'package:flutter/material.dart';

const double BUTTON_HEIGHT = 48;

class FocusRaisedButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool active;
  final bool autoFocus;
  final FocusNode focusNode;

  const FocusRaisedButton(
      {this.text, this.onPressed, this.active = true, this.autoFocus = false, this.focusNode});

  static const double FOCUSED_ELEVATION = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: TEXTFIELD_PADDING),
        child: ElevatedButton(
            autofocus: autoFocus ?? false,
            focusNode: focusNode,
            onPressed: onPressed,
            child: Text(text)));
  }
}

class FocusCheckButton extends StatelessWidget {
  final void Function(bool) onChanged;
  final bool checkValue;
  final String title;

  const FocusCheckButton({this.checkValue, this.title, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FocusWrap(
        onPressed: () {
          onChanged(!checkValue);
        },
        child: CheckboxListTile(
            value: checkValue,
            activeColor: Theme.of(context).accentColor,
            onChanged: onChanged,
            title: Text(title),
            controlAffinity: ListTileControlAffinity.trailing));
  }
}
