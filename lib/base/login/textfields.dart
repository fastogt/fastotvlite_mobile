import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';

const double TEXTFIELD_PADDING = 4;
const double TOTAL_TEXTFIELD_HEIGHT = 64;
const double ERROR_TEXT_HEIGHT = 24;

const String EMAIL = 'Email';
const String PASSWORD = 'Password';
const String SERVER = 'Server';
const String PORT = 'Port';

class TextFieldNode {
  final FocusNode main;
  final FocusNode text;

  TextFieldNode({this.main, this.text});
}

class LoginTextField extends StatefulWidget {
  final void Function(String term) onFieldChanged;
  final void Function(String term) onFieldSubmit;
  final String init;
  final String hintText;
  final String Function(String term) validator;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String errorText;

  final FocusNode mainFocus;
  final FocusNode textFocus;
  final FocusOnKeyCallback onKey;
  final bool autoFocus;

  const LoginTextField(
      {this.onKey,
      this.init,
      this.onFieldSubmit,
      this.onFieldChanged,
      this.mainFocus,
      this.textFocus,
      this.hintText,
      this.validator,
      this.controller,
      this.keyboardType,
      this.obscureText,
      this.errorText,
      this.autoFocus});

  @override
  _LoginTextFieldState createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool _validator = true;

  TextEditingController _controller;

  FocusNode _text = FocusNode(skipTraversal: true);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.init ?? '');
    widget.mainFocus?.addListener(update);
  }

  @override
  void didUpdateWidget(LoginTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.init != oldWidget.init) {
      _controller = widget.controller ?? TextEditingController(text: widget.init ?? '');
    }
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
        errorBorder: _errorBorder(),
        enabledBorder: _border(),
        focusedBorder: _border(),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0));
    final child = TextFormField(
        validator: _validate,
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        focusNode: _text,
        obscureText: widget.obscureText ?? false,
        onChanged: _onField,
        onFieldSubmitted: (term) {
          widget.onFieldSubmit?.call(term);
          if (widget.mainFocus != null) {
            FocusScope.of(context).requestFocus(widget.mainFocus);
            _text = null;
            _text = FocusNode(skipTraversal: true);
          }
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

  void _onField(String term) {
    if (term.isNotEmpty != _validator) {
      setState(() => _validator = term.isNotEmpty);
    }

    widget.onFieldChanged?.call(term);
  }

  String _validate(String term) {
    if (widget.validator != null) {
      final _message = widget.validator(term);
      if (_message != null) {
        return _message;
      }
    }

    if (term.isEmpty) {
      if (widget.errorText?.isNotEmpty ?? false) {
        return widget.errorText;
      } else {
        return "${widget.hintText} can't be empty.";
      }
    }

    return null;
  }

  OutlineInputBorder _border() {
    if (widget.mainFocus?.hasPrimaryFocus ?? false) {
      return OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 4));
    }
    return OutlineInputBorder(borderSide: BorderSide(color: Theming.of(context).onBrightness()));
  }

  OutlineInputBorder _errorBorder() {
    OutlineInputBorder border = const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    if (widget.mainFocus?.hasPrimaryFocus ?? false) {
      border = border.copyWith(borderSide: border.borderSide.copyWith(width: 4));
    }
    return border;
  }

  void onEnter(FocusNode node) {
    FocusScope.of(context).requestFocus(_text);
  }

  void update() {
    setState(() {});
  }
}

class TextControllerListener extends StatefulWidget {
  final List<TextEditingController> controllers;
  final bool Function(String text) validator;
  final Widget Function(BuildContext context, bool valid) builder;

  const TextControllerListener(
      {@required this.controllers, @required this.builder, this.validator});

  @override
  _TextControllerListenerState createState() => _TextControllerListenerState();
}

class _TextControllerListenerState extends State<TextControllerListener> {
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _valid = _validate();
    widget.controllers.forEach((controller) {
      controller.addListener(_update);
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controllers.forEach((controller) {
      controller.removeListener(_update);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _valid);
  }

  bool _validate() {
    for (final TextEditingController controller in widget.controllers) {
      if (widget.validator != null) {
        if (!widget.validator(controller.text)) {
          return false;
        }
      } else if (controller.text.isEmpty) {
        return false;
      }
    }

    return true;
  }

  void _update() {
    final bool validation = _validate();
    if (_valid != validation) {
      setState(() {
        _valid = validation;
      });
    }
  }
}
