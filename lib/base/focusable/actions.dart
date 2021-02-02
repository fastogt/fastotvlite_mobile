import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/tv/key_code.dart';

bool onKey(RawKeyEvent event, bool Function(int code) onKey) {
  if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
    final RawKeyDownEvent rawKeyDownEvent = event;
    final RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
    final int code = rawKeyEventDataAndroid.keyCode;
    return onKey(code);
  }
  return false;
}

bool onKeyArrows(BuildContext context, RawKeyEvent event,
    {void Function() onEnter, void Function() onBack}) {
  return onKey(event, (key) {
    switch (key) {
      case ENTER:
      case KEY_CENTER:
        if (onEnter == null) {
          return false;
        }
        onEnter.call();
        return true;
      case BACKSPACE:
      case BACK:
        if (onBack == null) {
          return false;
        }
        onBack.call();
        return true;
      case KEY_UP:
        FocusScope.of(context).focusInDirection(TraversalDirection.up);
        return true;
      case KEY_DOWN:
        FocusScope.of(context).focusInDirection(TraversalDirection.down);
        return true;
      case KEY_RIGHT:
        FocusScope.of(context).focusInDirection(TraversalDirection.right);
        return true;
      case KEY_LEFT:
        FocusScope.of(context).focusInDirection(TraversalDirection.left);
        return true;
    }
    return false;
  });
}
