import 'dart:core';

import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/base/streams/live_timeline.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/base/streams/program_time.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';

const double INTERFACE_OPACITY = 0.5;
const double TIMELINE_HEIGHT = 6.0;
const double BUTTONS_LINE_HEIGHT = 72;
const double TEXT_HEIGHT = 20;
const double TEXT_PADDING = 16;

class BottomControls extends StatefulWidget {
  final ProgramsBloc programsBloc;
  final List<Widget> buttons;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final bool showName;

  BottomControls({this.programsBloc, this.buttons, this.height, this.backgroundColor, this.textColor, this.showName});

  @override
  _BottomControlsState createState() => _BottomControlsState();
}

class _BottomControlsState extends State<BottomControls> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo>(
        stream: widget.programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: BUTTONS_LINE_HEIGHT, width: BUTTONS_LINE_HEIGHT, child: CircularProgressIndicator());
          }
          return Material(
              elevation: 4,
              color: widget.backgroundColor ?? Theme.of(context).primaryColor,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: widget.height,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    timeLine(snapshot.data),
                    programName(snapshot.data),
                    buttons(snapshot.data)
                  ])));
        });
  }

  Widget timeLine(ProgrammeInfo program) {
    if (program == null) {
      return SizedBox();
    }
    return LiveTimeLine(programmeInfo: program, width: MediaQuery.of(context).size.width, height: TIMELINE_HEIGHT);
  }

  Widget buttons(ProgrammeInfo program) {
    final widthPadding = SizedBox(width: 16);
    return Container(
        height: BUTTONS_LINE_HEIGHT,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          widthPadding,
          LiveTime.current(programmeInfo: program, color: widget.textColor),
          Spacer(),
          Row(children: widget.buttons ?? [SizedBox()]),
          Spacer(),
          LiveTime.end(programmeInfo: program, color: widget.textColor),
          widthPadding
        ]));
  }

  Widget programName(ProgrammeInfo program) {
    if (program == null) {
      return SizedBox();
    }
    final text = AppLocalizations.toUtf8(program.title);
    final color = widget.textColor ?? Theming.of(context).onCustomColor(Theme.of(context).primaryColor);
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(text,
            style: TextStyle(fontSize: TEXT_HEIGHT, color: color), overflow: TextOverflow.ellipsis, maxLines: 1));
  }
}
