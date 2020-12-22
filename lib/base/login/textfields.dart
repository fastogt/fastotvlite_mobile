import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';

const double TEXTFIELD_PADDING = 4;
const double TOTAL_TEXTFIELD_HEIGHT = 64;
const double ERROR_TEXT_HEIGHT = 24;

const String EMAIL = 'Email';
const String PASSWORD = 'Password';
const String SERVER = 'Server';
const String PORT = 'Port';

OutlineInputBorder border(BuildContext context, FocusNode focus) {
  if (focus != null) {
    if (focus.hasPrimaryFocus) {
      return OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 4));
    }
  }
  return OutlineInputBorder(borderSide: BorderSide(color: Theming.of(context).onBrightness(), width: 1));
}

class TextFieldNode {
  final FocusNode main;
  final FocusNode text;

  TextFieldNode({this.main, this.text});

  void dispose() {
    main?.dispose();
    text?.dispose();
  }
}

class LoginTextField extends StatefulWidget {
  final Function onFieldSubmit;
  final Function onFieldChanged;
  final String hintText;
  final bool validate;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final bool obscureText;
  final String errorText;

  final FocusNode mainFocus;
  final FocusNode textFocus;
  final FocusOnKeyCallback onKey;
  final bool autofocus;

  const LoginTextField(
      {this.onKey,
      this.onFieldSubmit,
      this.onFieldChanged,
      this.mainFocus,
      this.textFocus,
      this.hintText,
      this.textEditingController,
      this.keyboardType,
      this.obscureText,
      this.validate,
      this.errorText,
      this.autofocus});

  @override
  _LoginTextFieldState createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  OutlineInputBorder errorBorder() {
    if (widget.mainFocus != null) {
      if (widget.mainFocus.hasPrimaryFocus) {
        return OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 4));
      }
    }
    return OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1));
  }

  String error() {
    if (widget.errorText != null) {
      return widget.errorText;
    }
    return widget.validate ? null : widget.hintText + ' can\'t be empty.';
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        autofocus: widget.autofocus ?? false,
        focusNode: widget.mainFocus,
        debugLabel: widget.hintText,
        onKey: widget.onKey,
        child: Padding(
            padding: const EdgeInsets.all(TEXTFIELD_PADDING),
            child: TextFormField(
                controller: widget.textEditingController,
                keyboardType: TextInputType.emailAddress,
                focusNode: widget.textFocus,
                obscureText: widget.obscureText ?? false,
                onFieldSubmitted: (term) {
                  widget.onFieldSubmit();
                },
                onChanged: (term) {
                  if (widget.onFieldChanged != null) {
                    widget.onFieldChanged();
                  }
                },
                decoration: InputDecoration(
                    hintText: widget.hintText,
                    errorBorder: errorBorder(),
                    enabledBorder: border(context, widget.mainFocus),
                    focusedBorder: border(context, widget.mainFocus),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    errorText: error()))));
  }
}
