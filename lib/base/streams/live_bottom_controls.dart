import 'dart:core';

import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/base/streams/live_timeline.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/base/streams/program_time.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';

const double INTERFACE_OPACITY = 0.5;
const double TIMELINE_HEIGHT = 6.0;
const double BUTTONS_LINE_HEIGHT = 72;
const double TEXT_HEIGHT = 20;
const double TEXT_PADDING = 16;

class BottomControls extends StatefulWidget {
  final ProgramsBloc programsBloc;
  final List<Widget>? buttons;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool? showName;

  const BottomControls(
      {required this.programsBloc,
      this.buttons,
      this.height,
      this.backgroundColor,
      this.textColor,
      this.showName});

  @override
  _BottomControlsState createState() => _BottomControlsState();
}

class _BottomControlsState extends State<BottomControls> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo?>(
        stream: widget.programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: BUTTONS_LINE_HEIGHT,
                width: BUTTONS_LINE_HEIGHT,
                child: CircularProgressIndicator());
          }
          return Material(
              elevation: 4,
              color: widget.backgroundColor ?? Theme.of(context).primaryColor,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: widget.height,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    timeLine(snapshot.data),
                    Row(children: <Widget>[
                      Expanded(child: programName(snapshot.data)),
                      detailsButton(snapshot.data)
                    ]),
                    buttons(snapshot.data)
                  ])));
        });
  }

  Widget timeLine(ProgrammeInfo? program) {
    if (program == null) {
      return const SizedBox();
    }
    return LiveTimeLine(
        programmeInfo: program, width: MediaQuery.of(context).size.width, height: TIMELINE_HEIGHT);
  }

  Widget buttons(ProgrammeInfo? program) {
    if (program == null) {
      return const SizedBox();
    }

    const widthPadding = SizedBox(width: 16);
    return SizedBox(
        height: BUTTONS_LINE_HEIGHT,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          widthPadding,
          LiveTime.current(programmeInfo: program, color: widget.textColor),
          const Spacer(),
          Row(children: widget.buttons ?? [const SizedBox()]),
          const Spacer(),
          LiveTime.end(programmeInfo: program, color: widget.textColor),
          widthPadding
        ]));
  }

  Widget programName(ProgrammeInfo? program) {
    if (program == null) {
      return const SizedBox();
    }
    final text = AppLocalizations.toUtf8(program.title);
    final color = widget.textColor ?? Theming.onCustomColor(Theme.of(context).primaryColor);
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(text,
            style: TextStyle(fontSize: TEXT_HEIGHT, color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1));
  }

  Widget detailsButton(ProgrammeInfo? p) {
    if (p == null) {
      return const SizedBox();
    }

    if (p.description != null) {
      final color = widget.textColor ?? Theming.onCustomColor(Theme.of(context).primaryColor);
      return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(Icons.info, color: color),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return _DetailsDialog(
                          name: p.title, category: p.category, description: p.description);
                    });
              }));
    }
    return const SizedBox();
  }
}

class _DetailsDialog extends StatelessWidget {
  final String name;
  final String? category;
  final String? description;

  const _DetailsDialog({required this.name, this.category, required this.description});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: const Text('Description'),
        children: _children);
  }

  Widget _header(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)));
  }

  Widget _text(String? text) {
    return Text(AppLocalizations.toUtf8(text ?? ''),
        softWrap: true, style: const TextStyle(fontSize: 16));
  }

  List<Widget> get _children {
    if (category != null) {
      return [
        _header('Name'),
        _text(name),
        const Divider(),
        _header('Category'),
        _text(category),
        const Divider(),
        _header('Description'),
        _text(description)
      ];
    }
    return [
      _header('Name'),
      _text(name),
      const Divider(),
      _header('Description'),
      _text(description)
    ];
  }
}
