import 'dart:async';

import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotv_dart/epg_parser.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:rxdart/rxdart.dart';

class ProgramsBloc {
  final LiveStream channel;
  final _currentProgramStream = BehaviorSubject<ProgrammeInfo>();
  final _programsListStream = BehaviorSubject<List<ProgrammeInfo>>();
  int _current = -1;
  Stream<List<ProgrammeInfo>> _programsStream;
  Timer _timer;
  bool isClosed = false;

  ProgramsBloc(this.channel) {
    if (channel.programs().isNotEmpty) {
      _setPrograms(this.channel.programs());
    } else {
      _programsStream = _getProgram(this.channel).asStream();
      _programsStream.listen(_setPrograms);
    }
    isClosed = false;
  }

  // private:
  Future<List<ProgrammeInfo>> _getProgram(LiveStream channel) async {
    if (channel.programs().isEmpty) {
      await channel.requestProgrammes();
    }
    var programs = channel.programs();
    if (programs.isNotEmpty) {
      return programs;
    }
    return null;
  }

  void _setPrograms(data) {
    if (!isClosed) {
      _addProgramList.add(data);
      if (data != null) {
        _updatePrograms(data);
      } else {
        _addProgram.add(null);
      }
    }
  }

  void _updatePrograms(data) {
    if (!isClosed) {
      ProgrammeInfo _currentProgram = _findCurrent();
      _addProgram.add(_currentProgram);
      _setTimer(_currentProgram);
    }
  }

  void _setTimer(ProgrammeInfo programmeInfo) {
    if (programmeInfo != null) {
      final curUtc = DateTime.now().millisecondsSinceEpoch;
      final time = (programmeInfo.stop - programmeInfo.start) - (curUtc - programmeInfo.start);
      _timer = Timer(Duration(milliseconds: time), () => _updatePrograms(null));
    }
  }

  ProgrammeInfo _findCurrent() {
    var curUtc = DateTime.now().millisecondsSinceEpoch;
    final program = channel.findProgrammeByTime(curUtc);
    final index = getCurrent(channel.programs());

    if (program.isEmpty) {
      _current = null;
      return null;
    } else {
      _current = index;
      return program.value;
    }
  }

  Sink get _addProgram => _currentProgramStream.sink;

  Sink get _addProgramList => _programsListStream.sink;

  // Public
  Stream get currentProgram => _currentProgramStream.stream;

  int get currentProgramIndex => _current;

  Stream get programsList => _programsListStream.stream;

  void dispose() {
    _currentProgramStream.close();
    _programsListStream.close();
    _timer?.cancel();
    isClosed = true;
  }
}
