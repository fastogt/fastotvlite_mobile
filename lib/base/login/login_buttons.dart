import 'package:fastotvlite/base/login/textfields.dart';
import 'package:flutter/material.dart';

const double BUTTON_HEIGHT = 48;

/// Buttons
class FocusRaisedButton extends StatefulWidget {
  final String text;
  final FocusNode focusNode;
  final Function onPressed;
  final FocusOnKeyCallback onKey;
  final bool active;
  final Color activeColor;

  FocusRaisedButton({this.onKey, this.text, this.focusNode, this.onPressed, this.active, this.activeColor});

  @override
  _FocusRaisedButtonState createState() => _FocusRaisedButtonState();
}

class _FocusRaisedButtonState extends State<FocusRaisedButton> {
  static const double FOCUSED_ELEVATION = 5;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Theme.of(context).accentColor;
    return Focus(
        focusNode: widget.focusNode,
        onKey: widget.onKey,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TEXTFIELD_PADDING),
            child: RaisedButton(
                focusColor: widget.active ? activeColor : Colors.grey,
                focusElevation: FOCUSED_ELEVATION,
                onPressed: () => widget.onPressed(),
                color: widget.active ? activeColor : Colors.grey,
                disabledColor: Colors.grey,
                child: Text(widget.text, style: TextStyle(color: Colors.white)))));
  }
}

/// CheckButton
class FocusCheckButton extends StatefulWidget {
  final FocusOnKeyCallback onKey;
  final void Function(bool) onChanged;
  final FocusNode focusNode;
  final bool checkValue;
  final Color color;
  final String title;

  FocusCheckButton({this.focusNode, this.onKey, this.checkValue, this.title, this.onChanged, this.color});

  @override
  _FocusCheckButtonState createState() => _FocusCheckButtonState();
}

class _FocusCheckButtonState extends State<FocusCheckButton> {
  @override
  Widget build(BuildContext context) {
    return Focus(
        onKey: widget.onKey,
        focusNode: widget.focusNode,
        child: Center(
            child: CheckboxListTile(
                value: widget.checkValue,
                activeColor: widget.color,
                onChanged: (bool value) => widget.onChanged(value),
                title: Text(widget.title),
                controlAffinity: ListTileControlAffinity.trailing)));
  }
}
