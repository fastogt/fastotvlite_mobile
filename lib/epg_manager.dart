import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotv_dart/epg_parser.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:http/http.dart' as http;

class EpgManager {
  static const int MAX_PROGRAMS_COUNT = 100;
  static EpgManager? _instance;
  final http.Client _fetcher = http.Client();
  String? _epgUrl;
  final Map<String, List<ProgrammeInfo>> _cache = {};

  static Future<EpgManager> getInstance() async {
    _instance ??= EpgManager();
    return _instance!;
  }

  void setEpgUrl(String? epgUrl) {
    _epgUrl = epgUrl;
  }

  List<ProgrammeInfo>? getEpg(String epgId) {
    return _cache[epgId];
  }

  Future<List<ProgrammeInfo>> requestEpg(String epgId) {
    final result = _epgHttpRequest(epgId);
    result.then((value) {
      _cache[epgId] = value;
    });
    return result;
  }

  // private:
  Future<List<ProgrammeInfo>> _epgHttpRequest(String epgId) async {
    if (_epgUrl == null) {
      return [];
    }

    if (_epgUrl!.isEmpty || epgId.isEmpty) {
      return [];
    }

    final response = await _fetcher.get(Uri.parse('$_epgUrl/$epgId.xml'));
    if (response.statusCode != 200) {
      return [];
    }

    List<ProgrammeInfo> programs = parseXmlContent(response.body);
    if (programs.length > MAX_PROGRAMS_COUNT) {
      final _timeManager = locator<TimeManager>();
      final int curUtc = await _timeManager.realTime();
      final last = _sliceLastByTime(programs, curUtc);
      if (last.length > MAX_PROGRAMS_COUNT) {
        last.length = MAX_PROGRAMS_COUNT;
      }
      programs = last;
    }
    return programs;
  }

  static List<ProgrammeInfo> _sliceLastByTime(List<ProgrammeInfo> origin, int time) {
    for (int i = 0; i < origin.length; ++i) {
      final pr = origin[i];
      if (time >= pr.start && time <= pr.stop) {
        return origin.sublist(i);
      }
    }

    return <ProgrammeInfo>[];
  }
}
