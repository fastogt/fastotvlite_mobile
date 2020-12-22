import 'package:fastotv_dart/commands_info/meta_url.dart';
import 'package:fastotv_dart/commands_info/movie_info.dart';
import 'package:fastotv_dart/commands_info/stream_base_info.dart';
import 'package:fastotv_dart/commands_info/vod_info.dart';
import 'package:fastotvlite/channels/istream.dart';

class VodStream extends IStream {
  VodStream(VodInfo channel) : _channelInfo = channel;

  String id() {
    return _channelInfo.id;
  }

  void setId(String value) {
    _channelInfo.id = value;
  }

  String primaryUrl() {
    return _channelInfo.primaryLink();
  }

  void setPrimaryUrl(String value) {
    _channelInfo.vod.urls[0] = value;
  }

  String displayName() {
    return _channelInfo.displayName();
  }

  void setDisplayName(String value) {
    _channelInfo.vod.display_name = value;
  }

  double userScore() {
    return _channelInfo.getUserScore();
  }

  int duration() {
    return _channelInfo.getDuration();
  }

  int primeDate() {
    return _channelInfo.getDate();
  }

  String trailerUrl() {
    return _channelInfo.getTrailerUrl();
  }

  String country() {
    return _channelInfo.getCountry();
  }

  List<String> groups() {
    return _channelInfo.groups;
  }

  void setGroups(List<String> value) {
    _channelInfo.groups = value;
  }

  String previewIcon() {
    return _channelInfo.vod.preview_icon;
  }

  String icon() {
    return previewIcon();
  }

  void setIcon(String value) {
    _channelInfo.vod.preview_icon = value;
  }

  String description() {
    return _channelInfo.vod.description;
  }

  void setDescription(String value) {
    _channelInfo.vod.description = value;
  }

  int iarc() {
    return _channelInfo.iarc;
  }

  void setIarc(int value) {
    _channelInfo.iarc = value;
  }

  bool favorite() {
    return _channelInfo.favorite;
  }

  void setFavorite(bool value) {
    _channelInfo.favorite = value;
  }

  int interruptTime() {
    return _channelInfo.interrupt_time;
  }

  void setInterruptTime(int value) {
    _channelInfo.interrupt_time = value;
  }

  int recentTime() {
    return _channelInfo.recent;
  }

  void setRecentTime(int value) {
    _channelInfo.recent = value;
  }

  final VodInfo _channelInfo;

  VodStream.empty()
      : _channelInfo = VodInfo('', <String>[], 21, false, 0, 0, false,
            MovieInfo([''], '', '', '', '', 0, 0, '', 0, MovieType.VODS), true, true, null, 0, <MetaUrl>[]);

  VodStream.fromJson(Map<String, dynamic> json)
      : _channelInfo = VodInfo(
            json[StreamBaseInfo.ID_FIELD],
            json[StreamBaseInfo.GROUPS_FIELD].cast<String>(),
            json[StreamBaseInfo.IARC_FIELD],
            json[StreamBaseInfo.FAVORITE_FIELD],
            json[StreamBaseInfo.RECENT_FIELD],
            json[StreamBaseInfo.INTERRUPT_TIME_FIELD] ?? 0,
            false,
            MovieInfo(
                [json[MovieInfo.URLS_FIELD]],
                json[MovieInfo.DESCRIPTION_FIELD],
                json[MovieInfo.DISPLAY_NAME_FIELD],
                json[MovieInfo.PREVIEW_ICON_FIELD],
                json[MovieInfo.TRAILER_URL_FIELD] ?? '',
                json[MovieInfo.USER_SCORE_FIELD],
                json[MovieInfo.PRIME_DATE_FIELD],
                json[MovieInfo.COUNTRY_FIELD],
                json[MovieInfo.DURATION_FIELD],
                MovieType.VODS),
            true,
            true,
            null,
            0,
            <MetaUrl>[]);

  Map<String, dynamic> toJson() => {
        StreamBaseInfo.ID_FIELD: id(),
        StreamBaseInfo.GROUPS_FIELD: groups(),
        StreamBaseInfo.IARC_FIELD: iarc(),
        StreamBaseInfo.FAVORITE_FIELD: favorite(),
        StreamBaseInfo.RECENT_FIELD: recentTime(),
        StreamBaseInfo.INTERRUPT_TIME_FIELD: interruptTime(),
        MovieInfo.DESCRIPTION_FIELD: description(),
        MovieInfo.URLS_FIELD: primaryUrl(),
        MovieInfo.DISPLAY_NAME_FIELD: displayName(),
        MovieInfo.PREVIEW_ICON_FIELD: icon(),
        MovieInfo.DURATION_FIELD: duration(),
        MovieInfo.COUNTRY_FIELD: country(),
        MovieInfo.USER_SCORE_FIELD: userScore(),
        MovieInfo.PRIME_DATE_FIELD: primeDate(),
      };
}
