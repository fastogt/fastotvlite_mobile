import 'package:fastotvlite/base/focusable/actions.dart';
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
      return OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).accentColor, width: 4));
    }
  }
  return OutlineInputBorder(borderSide: BorderSide(color: Theming.of(context).onBrightness()));
}

class TextFieldNode {
  final FocusNode main;
  final FocusNode text;

  TextFieldNode({this.main, this.text});
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
  final bool autoFocus;

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
      this.autoFocus});

  @override
  _LoginTextFieldState createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  OutlineInputBorder errorBorder() {
    if (widget.mainFocus != null) {
      if (widget.mainFocus.hasPrimaryFocus) {
        return const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 4));
      }
    }
    return const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
  }

  String error() {
    if (widget.errorText != null) {
      return widget.errorText;
    }
    return widget.validate ? null : widget.hintText + ' can\'t be empty.';
  }

  FocusNode _text = FocusNode(skipTraversal: true);

  @override
  void initState() {
    super.initState();
    widget.mainFocus?.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.mainFocus?.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
        hintText: widget.hintText,
        errorBorder: errorBorder(),
        enabledBorder: border(context, widget.mainFocus),
        focusedBorder: border(context, widget.mainFocus),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        errorText: error());
    final child = TextFormField(
        controller: widget.textEditingController,
        keyboardType: TextInputType.emailAddress,
        focusNode: _text,
        obscureText: widget.obscureText ?? false,
        onFieldSubmitted: (term) {
          widget.onFieldSubmit?.call();
          if (widget.mainFocus != null) {
            FocusScope.of(context).requestFocus(widget.mainFocus);
            _text = null;
            _text = FocusNode(skipTraversal: true);
          }
        },
        onChanged: (term) {
          widget.onFieldChanged?.call();
        },
        decoration: decoration);

    return Focus(
        autofocus: widget.autoFocus ?? false,
        focusNode: widget.mainFocus,
        debugLabel: widget.hintText,
        onKey: (node, event) {
          return onKeyArrows(context, event, onEnter: () {
            FocusScope.of(context).requestFocus(_text);
          });
        },
        child: Padding(padding: const EdgeInsets.all(TEXTFIELD_PADDING), child: child));
  }

  void onEnter(FocusNode node) {
    FocusScope.of(context).requestFocus(_text);
  }

  void update() {
    setState(() {});
  }
}
