import 'package:flutter/material.dart';

class FocusBorder extends StatefulWidget {
  final FocusNode focus;
  final Widget child;

  const FocusBorder({@required this.focus, @required this.child});

  @override
  _FocusBorderState createState() => _FocusBorderState();
}

class _FocusBorderState extends State<FocusBorder> {
  Color _color = Colors.transparent;

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focus.removeListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: _color, width: 2)),
        child: widget.child);
  }

  void _onFocusChange() {
    setState(() {
      if (widget.focus.hasPrimaryFocus) {
        _color = Theme.of(context).accentColor;
      } else {
        _color = Colors.transparent;
      }
    });
  }
}
