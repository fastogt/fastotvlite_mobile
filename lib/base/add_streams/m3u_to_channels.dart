import 'package:fastotv_dart/commands_info/channel_info.dart';
import 'package:fastotv_dart/commands_info/epg_info.dart';
import 'package:fastotv_dart/commands_info/meta_url.dart';
import 'package:fastotv_dart/commands_info/movie_info.dart';
import 'package:fastotv_dart/commands_info/vod_info.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';

enum StreamType { Live, Vod }

class AddStreamResponse {
  StreamType type;
  List<LiveStream> channels = [];
  List<VodStream> vods = [];

  AddStreamResponse(this.type, {this.channels, this.vods});
}

const ID_FIELD = 'id';
const NAME_FIELD = 'name';
const PRIMARY_URL_FIELD = 'url';
const GROUP_FIELD = 'group';
const ICON_FIELD = 'icon';

class M3UParser {
  M3UParser(this.file, this.type);

  final String file;
  final StreamType type;

  static const CHANNELS_DIVIDER = '#EXTINF:-1';
  static const NAME_TAG = 'tvg-name=';
  static const ID_TAG = 'tvg-id=';
  static const ICON_TAG = 'tvg-logo=';
  static const GROUP_TAG = 'group-title=';

  // public
  Future<AddStreamResponse> parseChannelsFromString() async {
    final streams = _splitChannelInfo(file);
    if (streams == null) {
      return null;
    }
    if (type == StreamType.Live) {
      return AddStreamResponse(type, channels: streams);
    }
    return AddStreamResponse(type, vods: streams);
  }

  // private
  LiveStream _createLiveStream(Map<String, dynamic> m3u) {
    final settings = locator<LocalStorageService>();
    final String _epgLink = settings.epgLink();
    final _epg = EpgInfo(m3u[ID_FIELD], [m3u[PRIMARY_URL_FIELD]], m3u[NAME_FIELD], m3u[ICON_FIELD], []);
    final _channelInfo =
        ChannelInfo(m3u[ID_FIELD], m3u[GROUP_FIELD], 21, false, 0, 0, false, _epg, true, true, null, 0, <MetaUrl>[]);

    return LiveStream(_channelInfo, _epgLink);
  }

  VodStream _createVodStream(Map<String, dynamic> m3u) {
    final _movieInfo =
        MovieInfo([m3u[PRIMARY_URL_FIELD]], '', m3u[NAME_FIELD], m3u[ICON_FIELD], '', 0.0, 0, '', 0, MovieType.VODS);
    final vodInfo =
        VodInfo(m3u[ID_FIELD], m3u[GROUP_FIELD], 21, false, 0, 0, false, _movieInfo, true, true, null, 0, <MetaUrl>[]);

    return VodStream(vodInfo);
  }

  _TagsM3U _splitTag(String _tags) {
    final _TagsM3U tags = _TagsM3U();

    void _addTag(String tag, String info) {
      if (tag.contains(ID_TAG)) {
        tags.id = info;
      } else if (tag.contains(NAME_TAG)) {
        tags.name = info;
      } else if (tag.contains(GROUP_TAG)) {
        tags.group = [info];
      } else if (tag.contains(ICON_TAG)) {
        tags.icon = info;
      }
    }

    final _temp = _tags.split('"');
    for (int i = 0; i < _temp.length; i++) {
      if (i + 1 >= _temp.length) {
        break;
      }
      _addTag(_temp[i], _temp[i + 1]);
      i++;
    }
    return tags;
  }

  Map<String, dynamic> _splitM3U(String channel) {
    final List<String> _infoAndLink = channel.split('\n');
    final String _info = _infoAndLink[0];
    final List<String> _tagAndName = _info.split(',');
    final _TagsM3U _tagList = _splitTag(_info.substring(0, _info.length - _tagAndName.last.length));

    return {
      ID_FIELD: _tagList.id,
      ICON_FIELD: _tagList.icon,
      GROUP_FIELD: _tagList.group,
      NAME_FIELD: _tagAndName.last,
      PRIMARY_URL_FIELD: _infoAndLink[1]
    };
  }

  List<dynamic> _splitChannelInfo(String streamsString) {
    final List<LiveStream> channels = [];
    final List<VodStream> vods = [];

    List<String> result = [];

    final divider = _findDivider(streamsString);
    try {
      result = streamsString?.split(divider);
    } catch (e) {
      return null;
    }
    for (int i = 0; i < result.length; i++) {
      if (i > 0) {
        final _m3u = _splitM3U(result[i]);
        if (type == StreamType.Live) {
          final liveStream = _createLiveStream(_m3u);
          channels.add(liveStream);
        } else {
          final vodStream = _createVodStream(_m3u);
          vods.add(vodStream);
        }
      }
    }
    return type == StreamType.Live ? channels : vods;
  }

  String _findDivider(String m3u) {
    final reg = RegExp('#EXTINF:-1([ -~]*)tvg');
    final _match = reg.firstMatch(m3u)?.group(0);
    try {
      return _match?.split('tvg')[0];
    } catch (e) {
      return null;
    }
  }
}

class _TagsM3U {
  String id;
  String name;
  String icon;
  List<String> group;

  _TagsM3U({this.group, this.icon, this.id, this.name});
}
