import 'package:fastotvlite/events/tv_events.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class ClockFormatPickerTV extends StatefulWidget {
  const ClockFormatPickerTV();

  @override
  _ClockFormatPickerTVState createState() {
    return _ClockFormatPickerTVState();
  }
}

class _ClockFormatPickerTVState extends State<ClockFormatPickerTV> {
  int _currentSelection = 0;

  List<Locale> get supportedLocales =>
      AppLocalizations
          .of(context)
          .supportedLocales;

  @override
  Widget build(BuildContext context) {
    return Focus(
        canRequestFocus: false,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_dialogItem('13:00', 0), _dialogItem('1:00 PM', 1)]));
  }

  Widget _dialogItem(String text, int itemvalue) {
    return RadioListTile(
        activeColor: Theme
            .of(context)
            .accentColor,
        title: Text(text, style: const TextStyle(fontSize: 20)),
        value: itemvalue,
        groupValue: _currentSelection,
        onChanged: _changeFormat);
  }

  void _changeFormat(int value) async {
    _currentSelection = value;
    final bool is24 = value == 0;
    final settings = locator<LocalStorageService>();
    settings.setTimeFormat(is24);
    final tvTabsEvents = locator<TvTabsEvents>();
    tvTabsEvents.publish(ClockFormatChanged(is24));
    setState(() {});
  }
}
