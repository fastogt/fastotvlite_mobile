import 'dart:async';

import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/epg_manager.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:flutter_common/managers.dart';
import 'package:rxdart/rxdart.dart';

class ProgramsBloc {
  final LiveStream channel;
  final _currentProgramStream = BehaviorSubject<ProgrammeInfo?>();
  final _programsListStream = BehaviorSubject<List<ProgrammeInfo>?>();
  int? _current;
  Stream<List<ProgrammeInfo>>? _programsStream;
  Timer? _timer;
  bool isClosed = false;

  ProgramsBloc(this.channel) {
    List<ProgrammeInfo>? programs = channel.programs();
    if (programs.isEmpty) {
      final epg = locator<EpgManager>();
      programs = epg.getEpg(channel.epgId());
    }

    // need to request
    if (programs == null) {
      final epg = locator<EpgManager>();
      final request = epg.requestEpg(channel.epgId());
      _programsStream = request.asStream();
      _programsStream?.listen(_setPrograms);
      return;
    }

    _setPrograms(programs);
  }

  // private:
  void _setPrograms(List<ProgrammeInfo> data) {
    channel.setPrograms(data);
    if (isClosed) {
      return;
    }

    if (data.isNotEmpty) {
      _addProgramList.add(data);
      _updatePrograms();
    } else {
      _addProgramList.add(null);
      _addProgram.add(null);
    }
  }

  void _updatePrograms() async {
    if (isClosed) {
      return;
    }

    final ProgrammeInfo? _currentProgram = await _findCurrent();
    _addProgram.add(_currentProgram);
    _setTimer(_currentProgram);
  }

  void _setTimer(ProgrammeInfo? programmeInfo) async {
    if (programmeInfo == null) {
      return;
    }

    final _timeManager = locator<TimeManager>();
    final curUtc = await _timeManager.realTime();
    final time = (programmeInfo.stop - programmeInfo.start) - (curUtc - programmeInfo.start);
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: time), () => _updatePrograms());
  }

  Future<ProgrammeInfo?> _findCurrent() async {
    final _timeManager = locator<TimeManager>();
    final int curUtc = await _timeManager.realTime();
    final program = channel.findProgrammeByTime(curUtc);
    _current = await _getCurrent(channel.programs());

    if (program == null) {
      return null;
    }

    return program;
  }

  Future<int?> _getCurrent(List<ProgrammeInfo> programs) async {
    final _timeManager = locator<TimeManager>();
    final int curUtc = await _timeManager.realTime();
    for (int i = 0; i < programs.length; i++) {
      if (curUtc >= programs[i].start && curUtc <= programs[i].stop) {
        return i;
      }
    }
    return null;
  }

  Sink get _addProgram => _currentProgramStream.sink;

  Sink get _addProgramList => _programsListStream.sink;

  // Public
  Stream<ProgrammeInfo?> get currentProgram => _currentProgramStream.stream;

  int? get currentProgramIndex => _current;

  Stream<List<ProgrammeInfo>?> get programsList => _programsListStream.stream;

  void dispose() {
    _currentProgramStream.close();
    _programsListStream.close();
    _timer?.cancel();
    isClosed = true;
  }
}
