import 'package:fastotvlite/base/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';

class StreamTypePickerTV extends StatefulWidget {
  StreamTypePickerTV();

  @override
  _StreamTypePickerTVState createState() => _StreamTypePickerTVState();
}

class _StreamTypePickerTVState extends State<StreamTypePickerTV> {
  PickStreamFrom _source;

  Widget build(context) {
    return AlertDialog(
        title: Text('Select stream type'),
        titlePadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        actions: <Widget>[
          _button('CANCEL', () => _exit(), 1.0),
          _button('OK', () => _onProceed(), _source == null ? 0.5 : 1.0)
        ],
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_typeTile(PickStreamFrom.PLAYLIST), _typeTile(PickStreamFrom.SINGLE_STREAM)]));
  }

  Widget _typeTile(PickStreamFrom value) {
    return ListTile(
        title: Text(AppLocalizations.of(context)
            .translate(value == PickStreamFrom.SINGLE_STREAM ? TR_SINGLE_STREAM : TR_PLAYLIST)),
        leading: Radio(
            autofocus: true,
            groupValue: _source,
            value: value,
            onChanged: (PickStreamFrom value) => setState(() => _source = value)));
  }

  Widget _button(String text, void Function() onPressed, double opacity) {
    final buttonTextColor = Theming.of(context).onBrightness().withOpacity(opacity);
    return FlatButton(child: Text(text, style: TextStyle(color: buttonTextColor)), onPressed: onPressed);
  }

  void _exit({PickStreamFrom source}) => Navigator.of(context).pop(_source);

  void _onProceed() async {
    if (_source != null) {
      _exit(source: _source);
    }
  }
}
