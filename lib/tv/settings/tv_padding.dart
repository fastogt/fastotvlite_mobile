import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/utils.dart';

class PaddingSettings extends StatefulWidget {
  final void Function(double value) setPadding;

  const PaddingSettings(this.setPadding);

  @override
  _PaddingSettingsState createState() {
    return _PaddingSettingsState();
  }
}

class _PaddingSettingsState extends State<PaddingSettings> {
  double percent;
  TextStyle textStyle = const TextStyle(fontSize: 32);
  TextStyle symbolsStyle;
  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    percent = settings.screenScale();
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    symbolsStyle = TextStyle(fontSize: 32, color: _iconsColor());
    return Focus(
        focusNode: _node,
        onKey: _listControl,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(padding: const EdgeInsets.all(8.0), child: Text('+', style: symbolsStyle)),
          Center(child: Text((percent * 100).toStringAsFixed(1) + '%', style: textStyle)),
          Padding(padding: const EdgeInsets.all(8.0), child: Text('-', style: symbolsStyle))
        ]));
  }

  KeyEventResult _listControl(FocusNode node, RawKeyEvent event) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KEY_UP:
          if (percent < 1) {
            percent += 0.001;
            widget.setPadding(percent);
          }
          return KeyEventResult.handled;
        case KEY_DOWN:
          if (percent > 0.9) {
            percent -= 0.001;
            widget.setPadding(percent);
          }
          return KeyEventResult.handled;
        case KEY_LEFT:
          final settings = locator<LocalStorageService>();
          settings.setScreenScale(percent);
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }

  Color _iconsColor() {
    if (_node.hasPrimaryFocus) {
      return Theme
          .of(context)
          .accentColor;
    }
    return Colors.transparent;
  }

  void _onFocusChange() {
    setState(() {});
  }
}
