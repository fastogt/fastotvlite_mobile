import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/base/streams/no_programs.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

String formatProgram(ProgrammeInfo program) {
  final timeZoneOffset = DateTime.now().timeZoneOffset;
  return program.getStart(timeZoneOffset) +
      ' - ' +
      program.getEnd(timeZoneOffset) +
      ' / ' +
      program.getDuration();
}

class ProgramsListView extends StatefulWidget {
  final ProgramsBloc programsBloc;
  double? itemHeight;
  final Color textColor;

  ProgramsListView({required this.programsBloc, this.itemHeight, required this.textColor});

  @override
  _ProgramsListViewState createState() => _ProgramsListViewState();
}

class _ProgramsListViewState extends State<ProgramsListView> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: StreamBuilder(
            stream: widget.programsBloc.programsList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data == null) {
                return NoPrograms(widget.textColor);
              }
              final _index = widget.programsBloc.currentProgramIndex;
              final stabled = snapshot.data as List<ProgrammeInfo>;
              return _ProgramsList(
                  programs: stabled,
                  bloc: widget.programsBloc,
                  index: _index,
                  itemHeight: widget.itemHeight,
                  textColor: widget.textColor);
            }));
  }
}

class _ProgramsList extends StatefulWidget {
  final List<ProgrammeInfo> programs;
  final ProgramsBloc bloc;
  final int? index;
  final double? itemHeight;
  final Color textColor;

  const _ProgramsList(
      {required this.programs,
      required this.bloc,
      this.index,
      this.itemHeight,
      required this.textColor});

  @override
  _ProgramsListState createState() => _ProgramsListState();
}

class _ProgramsListState extends State<_ProgramsList> {
  static const ITEM_HEIGHT = 64.0;

  late CustomScrollController _scrollController;
  ProgrammeInfo? programmeInfo;
  int? _current;
  late double _itemHeight;

  @override
  void initState() {
    super.initState();
    _itemHeight = widget.itemHeight ?? ITEM_HEIGHT;
    _current = widget.index;
    programmeInfo = widget.programs[_current!];
    _scrollController =
        CustomScrollController(itemHeight: _itemHeight, initOffset: _itemHeight * _current!);
    _initCurrentProgramSubscription();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const SizedBox(),
        itemCount: widget.programs.length,
        controller: _scrollController.controller,
        itemBuilder: (BuildContext context, int index) {
          final program = widget.programs[index];
          final curUtc = DateTime.now().millisecondsSinceEpoch;
          final elevation = index == _current ? 1.0 : 0.0;
          final currentColor = curUtc >= program.start && curUtc < program.stop
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent;
          return Opacity(
              opacity: curUtc < program.stop ? 1.0 : 0.4,
              child: Material(
                  elevation: elevation,
                  color: Colors.transparent,
                  child: Container(
                      height: _itemHeight,
                      decoration: BoxDecoration(border: Border.all(color: currentColor, width: 2)),
                      child: _ProgramListTile(program: program, textColor: widget.textColor))));
        });
  }

  void _initCurrentProgramSubscription() {
    widget.bloc.currentProgram.listen((program) {
      programmeInfo = program;
      _current = widget.bloc.currentProgramIndex;
      if (_scrollController.controller!.hasClients && _current != null) {
        _scrollController.jumpToPosition(_current!);
        if (mounted) {
          setState(() {});
        }
      }
    });
  }
}

class _ProgramListTile extends StatefulWidget {
  final ProgrammeInfo program;
  final Color? textColor;

  const _ProgramListTile({required this.program, this.textColor});

  @override
  _ProgramListTileState createState() => _ProgramListTileState();
}

class _ProgramListTileState extends State<_ProgramListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        dense: true,
        onTap: () {},
        title: Text(AppLocalizations.toUtf8(widget.program.title),
            style: TextStyle(fontSize: 16, color: widget.textColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false),
        subtitle: Opacity(
            opacity: 0.6,
            child: Text(formatProgram(widget.program), style: TextStyle(color: widget.textColor))));
  }
}
