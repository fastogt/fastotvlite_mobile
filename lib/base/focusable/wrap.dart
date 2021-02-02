import 'package:flutter/material.dart';
import 'package:fastotvlite/base/focusable/actions.dart';

class FocusWrap extends StatelessWidget {
  final FocusNode focus;
  final void Function() onPressed;
  final Widget child;

  const FocusWrap({@required this.child, this.onPressed, this.focus});

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: focus ?? FocusNode(),
        onKey: (node, event) {
          return onKeyArrows(context, event, onEnter: onPressed);
        },
        child: child);
  }
}
