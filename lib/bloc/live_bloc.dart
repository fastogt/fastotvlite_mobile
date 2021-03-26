import 'package:fastotvlite/base/stream_parser.dart';
import 'package:fastotvlite/bloc/base_bloc.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/tv/streams/tv_live_player.dart';
import 'package:flutter/material.dart';

import 'package:fastotvlite/mobile/streams/live_player_page.dart';

class LiveStreamBloc extends BaseStreamBloc<LiveStream> {
  LiveStreamBloc(List<LiveStream> streams, NavigatorState navigator) : super(streams, navigator);

  @override
  Map<String, List<LiveStream>> parseMap(List<LiveStream> streams) {
    return StreamsParser<LiveStream>(streams).parseChannels();
  }

  @override
  void onSearch(LiveStream stream) => onTap([stream], 0);

  @override
  void saveStreams() {
    final settings = locator<LocalStorageService>();
    settings.saveLiveChannels(map[TR_ALL]);
  }

  void onTap(List<LiveStream> channels, int position, [void Function() onExit]) async {
    navigator.push(MaterialPageRoute(builder: (context) {
      return ChannelPage(channels: channels, position: position, addRecent: addRecent);
    })).then((lastPosition) {});
    onExit?.call();
    if (category == TR_RECENT) {
      sortRecent();
    }
    final settings = locator<LocalStorageService>();
    settings.setLastChannel(null);
  }
}

class LiveStreamBlocTV extends LiveStreamBloc {
  LiveStreamBlocTV(List<LiveStream> streams, NavigatorState navigator) : super(streams, navigator);

  @override
  void onSearch(LiveStream s) {}

  Widget playerPage(List<LiveStream> channels, int position) {
    return TvLivePlayerPage(channels[position]);
  }
}
