import 'dart:async';
import 'dart:core';

import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/base_tab.dart';
import 'package:fastotvlite/mobile/streams/live_player_page.dart';
import 'package:fastotvlite/mobile/streams/live_tile.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/screen_orientation.dart' as orientation;

class LiveTab extends BaseListTab<LiveStream> {
  LiveTab(key, channels) : super(key, channels);

  @override
  LiveVideoAppState createState() => LiveVideoAppState();
}

class LiveVideoAppState extends VideoAppState<LiveStream> with ILiveFutureTileObserver {
  StreamController<LiveStream> recentlyViewed = StreamController<LiveStream>.broadcast();

  String noRecent() => AppLocalizations.of(context).translate(TR_RECENT_LIVE);

  String noFavorite() => AppLocalizations.of(context).translate(TR_FAVORITE_LIVE);

  @override
  void initState() {
    super.initState();
    recentlyViewed.stream.asBroadcastStream().listen((channel) => addRecent(channel));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lastViewed();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    recentlyViewed.close();
  }

  ListView listBuilder(List<LiveStream> channels) {
    return ListView.separated(
        separatorBuilder: (context, int index) => Divider(height: 0),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return LiveFutureTile(channels: channels, index: index, observer: this);
        });
  }

  void onSearch(LiveStream stream) {
    onTap([stream], 0);
  }

  void onTapped(List<LiveStream> channels, int position) async {
    final channelsList = channels;
    orientation.allowAll();
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChannelPage(position: position, channels: channelsList, stream: recentlyViewed)));
    if (tabController.index == 1) sortRecent();
    final settings = locator<LocalStorageService>();
    settings.setLastChannel(null);
  }

  void onDelete(LiveStream stream) {
    widget.channels.remove(stream);
  }

  void onLongTapped(LiveStream stream) async {
    handleStreamEdit();
  }

  void onTap(List<LiveStream> streams, int position) {
    onTapped(streams, position);
  }

  void onLongTap(LiveStream stream) {
    onLongTapped(stream);
  }

  void onAddFavorite(LiveStream stream) {
    addFavorite(stream);
  }

  void onDeleteFavorite(LiveStream stream) {
    deleteFavorite(stream);
  }

  void _lastViewed() {
    final settings = locator<LocalStorageService>();
    final isSaved = settings.saveLastViewed();

    if (!isSaved) {
      return;
    }

    final lastChannelID = settings.lastChannel();
    if (lastChannelID == null) {
      return;
    }

    final channels = super.channelsMap[TR_ALL];
    for (int i = 0; i < channels.length; i++) {
      if (channels[i].id() == lastChannelID) {
        openChannel(channels, i);
        return;
      }
    }
  }
}
