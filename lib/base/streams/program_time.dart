import 'dart:async';

import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';

class LiveTime extends StatefulWidget {
  final ProgrammeInfo programmeInfo;
  final bool isLive;
  final Color color;

  LiveTime.current({@required this.programmeInfo, this.color}) : isLive = true;

  LiveTime.end({@required this.programmeInfo, this.color}) : isLive = false;

  @override
  createState() => LiveTimeState();
}

class LiveTimeState<T extends LiveTime> extends State<T> {
  static const REFRESH_TIMELINE_SEC = 1;

  Timer _timer;
  String _timeString = '';

  int start;
  int stop;

  @override
  void initState() {
    super.initState();
    initTimeline(widget.programmeInfo);
  }

  @override
  void didUpdateWidget(LiveTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.programmeInfo != widget.programmeInfo) {
      initTimeline(widget.programmeInfo);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theming.of(context).onCustomColor(Theme.of(context).primaryColor);
    return Text(_timeString, style: TextStyle(color: color));
  }

  @protected
  void initTimeline(ProgrammeInfo programmeInfo) {
    if (programmeInfo == null) {
      return;
    }
    start = programmeInfo.start;
    stop = programmeInfo.stop;
    _update(programmeInfo);
    if (widget.isLive) {
      _timer = Timer.periodic(Duration(seconds: REFRESH_TIMELINE_SEC), (Timer t) => _update(programmeInfo));
    }
  }

  // private:
  void _update(ProgrammeInfo programmeInfo) {
    _syncControls(programmeInfo);
    if (mounted) {
      setState(() {});
    }
  }

  void _syncControls(ProgrammeInfo programmeInfo) {
    if (programmeInfo == null) {
      return;
    }

    if (widget.isLive) {
      final curUtc = DateTime.now().millisecondsSinceEpoch;
      final passed = curUtc - start;

      if (curUtc > stop) {
        _timeString = _parse(0);
      } else {
        _timeString = _parse(passed);
      }
    } else {
      _timeString = _parse(stop - start);
    }
  }

  String _parse(int time) {
    String _twoDigits(int n) {
      if (n >= 10) {
        return "$n";
      }
      return "0$n";
    }

    String output = '';

    final startTime = Duration(milliseconds: time);
    final diff = startTime - Duration(days: startTime.inDays);
    final hours = diff.inHours;
    final minutes = (diff - Duration(hours: diff.inHours)).inMinutes;
    final seconds = (diff - Duration(hours: diff.inHours) - Duration(minutes: minutes)).inSeconds;
    if (hours > 0) {
      output += '$hours' + ':';
    }
    output += _twoDigits(minutes) + ':' + _twoDigits(seconds);
    return output;
  }
}
