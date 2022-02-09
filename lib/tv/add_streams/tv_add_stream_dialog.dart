import 'package:fastotvlite/base/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/base/login/textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/utils.dart';

class FilePickerDialogTV extends BaseFilePickerDialog {
  const FilePickerDialogTV(PickStreamFrom source) : super(source);

  @override
  _FilePickerDialogTVState createState() => _FilePickerDialogTVState();
}

class _FilePickerDialogTVState extends BaseFilePickerDialogState {
  final _textFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));

  @override
  void initState() {
    super.initState();
    _textFieldNode.main.addListener(() => setState(() {}));
  }

  @override
  Widget textField() {
    return LoginTextField(
        mainFocus: _textFieldNode.main,
        textFocus: _textFieldNode.text,
        controller: controller,
        hintText: hintText,
        obscureText: false,
        onKey: _nodeAction,
        onFieldSubmit: (_) => _onEnter(_textFieldNode.text));
  }

  KeyEventResult _nodeAction(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      final RawKeyDownEvent rawKeyDownEvent = event;
      final RawKeyEventDataAndroid rawKeyEventDataAndroid =
          rawKeyDownEvent.data as RawKeyEventDataAndroid;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          _onEnter(node);
          setState(() {});
          return KeyEventResult.handled;
        case KEY_LEFT:
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          setState(() {});
          return KeyEventResult.handled;
        case KEY_RIGHT:
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
          setState(() {});
          return KeyEventResult.handled;
        case KEY_UP:
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          setState(() {});
          return KeyEventResult.handled;
        case KEY_DOWN:
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          setState(() {});
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _onEnter(FocusNode node) {
    if (node == _textFieldNode.text) {
      FocusScope.of(context).requestFocus(_textFieldNode.main);
      validateLink();
    } else {
      FocusScope.of(context).requestFocus(_textFieldNode.text);
    }
  }
}
