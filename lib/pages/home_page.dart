import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/bloc/live_bloc.dart';
import 'package:fastotvlite/bloc/vod_bloc.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/events/ascending.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/streams/live_search.dart';
import 'package:fastotvlite/mobile/vods/vod_search.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

abstract class HomePage extends StatefulWidget {
  final List<LiveStream> channels;
  final List<VodStream> vods;

  const HomePage(this.channels, this.vods);
}

abstract class VideoAppState extends State<HomePage> {
  LiveStreamBloc? liveStreamsBloc;
  VodStreamBloc? vodStreamsBloc;

  List<LiveStream>? channels() {
    if (liveStreamsBloc?.map != null) {
      return liveStreamsBloc?.map[TR_ALL];
    }

    return null;
  }

  List<VodStream>? vods() {
    if (vodStreamsBloc?.map != null) {
      return vodStreamsBloc?.map[TR_ALL];
    }

    return null;
  }

  bool get channelsEmpty => channels()?.isEmpty ?? true;

  bool get vodsEmpty => vods()?.isEmpty ?? true;

  bool get isStreamsEmpty => channelsEmpty && vodsEmpty;

  List<String> videoTypesList = [];
  String selectedType;

  bool canRequest;

  String translate(String key) {
    return AppLocalizations.of(context)!.translate(key)!;
  }

  @override
  void initState() {
    super.initState();
    _fillTypes();
    final events = locator<ClientEvents>();
    events.subscribe<StreamsListEmptyEvent>().listen((_) => onTypeDelete());
  }

  SearchDelegate? get searchDelegate {
    switch (selectedType) {
      case TR_LIVE_TV:
        return LiveStreamSearch(widget.channels, translate(TR_SEARCH_LIVE));
      case TR_VODS:
        return VodStreamSearch(widget.vods, translate(TR_SEARCH_VOD));

      default:
        return null;
    }
  }

  void sendSearchEvent(IStream stream) {
    final _searchEvents = locator<SearchEvents>();
    switch (selectedType) {
      case TR_LIVE_TV:
        _searchEvents.publish(StreamSearchEvent<LiveStream>(stream));
        break;
      case TR_VODS:
        _searchEvents.publish(StreamSearchEvent<VodStream>(stream));
        break;
      default:
    }
  }

  String? checkLastType(List<IStream> list, String type) {
    final settings = locator<LocalStorageService>();
    final bool isSaved = settings.saveLastViewed();
    final String? lastChannel = settings.lastChannel();
    if (isSaved) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id() == lastChannel) {
          return type;
        }
      }
    }
    return null;
  }

  void onTypeDelete() {
    if (isStreamsEmpty) {
      selectedType = TR_EMPTY;
      videoTypesList.clear();
    } else {
      videoTypesList.remove(selectedType);
      selectedType = videoTypesList.first;
    }
    setState(() {});
  }

  void addStreams(AddStreamResponse response) {
    if (response.type == StreamType.Live) {
      _addLiveStreams(response.channels);
    } else {
      _addVodStreams(response.vods);
    }
  }

  // private
  void _fillTypes() {
    String? lastType;
    if (widget.channels.isEmpty && widget.vods.isEmpty) {
      selectedType = TR_EMPTY;
      return;
    }
    if (widget.channels.isNotEmpty) {
      _fillLive(widget.channels);
      lastType ??= checkLastType(widget.channels, TR_LIVE_TV);
    }
    if (widget.vods.isNotEmpty) {
      _fillVods(widget.vods);
      lastType ??= checkLastType(widget.vods, TR_VODS);
    }
    if (lastType != null) {
      selectedType = videoTypesList.contains(lastType) ? lastType : videoTypesList[0];
    } else {
      selectedType = videoTypesList[0];
    }
  }

  void _addLiveStreams(List<LiveStream> streams) {
    if (!videoTypesList.contains(TR_LIVE_TV)) {
      _fillLive(streams);
    } else {
      streams.forEach(liveStreamsBloc.addStream);
    }
    liveStreamsBloc.updateMap();
    if (selectedType != TR_LIVE_TV) {
      setState(() {
        selectedType = TR_LIVE_TV;
      });
    }
  }

  void _addVodStreams(List<VodStream> streams) {
    if (!videoTypesList.contains(TR_VODS)) {
      _fillVods(streams);
    } else {
      streams.forEach(vodStreamsBloc.addStream);
    }
    vodStreamsBloc.updateMap();
    if (selectedType != TR_VODS) {
      setState(() {
        selectedType = TR_VODS;
      });
    }
  }

  void _fillLive(List<LiveStream> channels) {
    videoTypesList.add(TR_LIVE_TV);
    final device = locator<RuntimeDevice>();
    if (device.hasTouch) {
      liveStreamsBloc = LiveStreamBloc(channels, Navigator.of(context));
    } else {
      liveStreamsBloc = LiveStreamBlocTV(channels, Navigator.of(context));
    }
  }

  void _fillVods(List<VodStream> vods) {
    videoTypesList.add(TR_VODS);
    vodStreamsBloc = VodStreamBloc(vods, Navigator.of(context));
  }
}
