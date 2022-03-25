import 'dart:async';
import 'dart:core';

import 'package:fastotvlite/bloc/live_bloc.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/base_tab.dart';
import 'package:fastotvlite/mobile/streams/live_tile.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class LiveTab extends StatefulWidget {
  final LiveStreamBloc bloc;

  const LiveTab(Key key, this.bloc) : super(key: key);

  @override
  LiveVideoAppState createState() => LiveVideoAppState();
}

class LiveVideoAppState extends IStreamBaseListPage<LiveStream, LiveTab>
    with ILiveFutureTileObserver {
  StreamController<LiveStream> recentlyViewed = StreamController<LiveStream>.broadcast();

  @override
  LiveStreamBloc get bloc => widget.bloc;

  @override
  String noRecent() {
    return translate(context, TR_RECENT_LIVE);
  }

  @override
  String noFavorite() {
    return translate(context, TR_FAVORITE_LIVE);
  }

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

  @override
  ListView listBuilder(List<LiveStream> channels) {
    return ListView.separated(
        separatorBuilder: (context, int index) => const Divider(height: 0),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return LiveFutureTile(channels: channels, index: index, observer: this);
        });
  }

  @override
  void onTap(List<LiveStream> channels, int position) async {
    allowAll();
    bloc.onTap(channels, position);
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

    final channels = super.channelsMap[TR_ALL]!;
    for (int i = 0; i < channels.length; i++) {
      if (channels[i].id() == lastChannelID) {
        tabController.animateTo(1);
        onTap(channels, i);
        return;
      }
    }
  }
}
