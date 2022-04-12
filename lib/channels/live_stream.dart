import 'package:fastotv_dart/commands_info/channel_info.dart';
import 'package:fastotv_dart/commands_info/epg_info.dart';
import 'package:fastotv_dart/commands_info/meta_url.dart';
import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotv_dart/commands_info/stream_base_info.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/constants.dart';
import 'package:uuid/uuid.dart';

class LiveStream extends IStream {
  static const int MAX_PROGRAMS_COUNT = 100;
  final ChannelInfo _channelInfo;
  String _epgUrl;
  bool _requested = false;

  LiveStream(ChannelInfo channel, String epg)
      : _channelInfo = channel,
        _epgUrl = epg;

  String epgId() {
    return _channelInfo.epg.id;
  }

  @override
  String id() {
    return _channelInfo.id;
  }

  @override
  void setId(String value) {
    _channelInfo.id = value;
  }

  @override
  List<String> get urls {
    return _channelInfo.epg.urls;
  }

  @override
  String primaryUrl() {
    return _channelInfo.primaryLink();
  }

  @override
  void setPrimaryUrl(String value) {
    _channelInfo.epg.urls[0] = value;
  }

  @override
  String displayName() {
    return _channelInfo.displayName();
  }

  @override
  void setDisplayName(String value) {
    _channelInfo.epg.display_name = value;
  }

  @override
  List<String> groups() {
    return _channelInfo.groups;
  }

  @override
  void setGroups(List<String> value) {
    _channelInfo.groups = value;
  }

  String epgUrl() {
    return _epgUrl;
  }

  void setEpgUrl(String value) {
    _epgUrl = value;
  }

  @override
  String icon() {
    return _channelInfo.epg.icon;
  }

  @override
  void setIcon(String value) {
    _channelInfo.epg.icon = value;
  }

  @override
  int iarc() {
    return _channelInfo.iarc;
  }

  @override
  void setIarc(int value) {
    _channelInfo.iarc = value;
  }

  @override
  bool favorite() {
    return _channelInfo.favorite;
  }

  @override
  void setFavorite(bool value) {
    _channelInfo.favorite = value;
  }

  @override
  int recentTime() {
    return _channelInfo.recent;
  }

  @override
  void setRecentTime(int value) {
    _channelInfo.recent = value;
  }

  ProgrammeInfo? findProgrammeByTime(int time) {
    return _channelInfo.epg.findProgrammeByTime(time);
  }

  List<ProgrammeInfo> programs() {
    return _channelInfo.epg.programs;
  }

  void setPrograms(List<ProgrammeInfo> programs) {
    _channelInfo.epg.programs = programs;
  }

  void setRequested(bool requested) {
    _requested = requested;
    if (!_requested) {
      _channelInfo.epg.programs = [];
    }
  }

  // private:
  static const EPG_URL_FIELD = 'epg_url';
  static const REQUESTED_FIELD = 'requested';

  LiveStream.empty()
      : _channelInfo = ChannelInfo(const Uuid().v1(), <String>[], 0, false, 0, 0, false,
            EpgInfo('', [''], '', '', []), true, true, <String>[], 0, <MetaUrl>[], 0, true),
        _epgUrl = EPG_URL,
        _requested = false;

  LiveStream.fromJson(Map<String, dynamic> json)
      : _channelInfo = ChannelInfo(
            json[StreamBaseInfo.ID_FIELD],
            json[StreamBaseInfo.GROUPS_FIELD].cast<String>(),
            json[StreamBaseInfo.IARC_FIELD],
            json[StreamBaseInfo.FAVORITE_FIELD],
            json[StreamBaseInfo.RECENT_FIELD],
            0,
            false,
            EpgInfo(json[StreamBaseInfo.ID_FIELD], [json[EpgInfo.URLS_FIELD]],
                json[EpgInfo.DISPLAY_NAME_FIELD], json[EpgInfo.ICON_FIELD], []),
            true,
            true,
            <String>[],
            0,
            <MetaUrl>[],
            0,
            true),
        _epgUrl = json[EPG_URL_FIELD] ?? EPG_URL,
        _requested = false;

  Map<String, dynamic> toJson() => {
        StreamBaseInfo.ID_FIELD: id(),
        StreamBaseInfo.GROUPS_FIELD: groups(),
        StreamBaseInfo.IARC_FIELD: iarc(),
        StreamBaseInfo.FAVORITE_FIELD: favorite(),
        StreamBaseInfo.RECENT_FIELD: recentTime(),
        EpgInfo.URLS_FIELD: primaryUrl(),
        EpgInfo.DISPLAY_NAME_FIELD: displayName(),
        EpgInfo.ICON_FIELD: icon(),
        REQUESTED_FIELD: _requested,
        EPG_URL_FIELD: epgUrl()
      };
}
