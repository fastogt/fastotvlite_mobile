import 'package:fastotvlite/base/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/base/login/textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/utils.dart';

class FilePickerDialogTV extends BaseFilePickerDialog {
  final PickStreamFrom source;

  FilePickerDialogTV(this.source) : super(source);

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

  bool _nodeAction(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          _onEnter(node);
          break;
        case KEY_LEFT:
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          break;
        case KEY_RIGHT:
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
          break;
        case KEY_UP:
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          break;
        case KEY_DOWN:
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          break;
        default:
          break;
      }
      setState(() {});
    }
    return node.hasFocus;
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
