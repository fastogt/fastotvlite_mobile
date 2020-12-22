import 'dart:async';
import 'dart:core';

import 'package:fastotvlite/base/streams/live_bottom_controls.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/base/streams/programs_list.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/player/common_player.dart';
import 'package:fastotvlite/player/stream_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/player_buttons.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/screen_orientation.dart' as orientation;
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/base/controls/fullscreen_button.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_filler.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';

class ChannelPage extends StatefulWidget {
  final List<LiveStream> channels;
  final int position;
  final StreamController<LiveStream> stream;

  ChannelPage({this.channels, this.position, this.stream});

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends AppBarPlayerLive<ChannelPage> {
  ProgramsBloc programsBloc;
  int currentPos;
  StreamPlayerPage _playerPage;

  double bottomControlsHeight() {
    if (programsBloc.currentProgramIndex != null) {
      return 4 + BUTTONS_LINE_HEIGHT + TEXT_HEIGHT + TIMELINE_HEIGHT + TEXT_PADDING;
    } else {
      return 4 + BUTTONS_LINE_HEIGHT;
    }
  }

  bool isPlaying() {
    if (ChromeCastInfo().castConnected) {
      return ChromeCastInfo().isPlaying();
    } else {
      return _playerPage.isPlaying();
    }
  }

  void play() => _playerPage.play();

  void pause() => _playerPage.pause();

  void onLongTapLeft() {}

  void onLongTapRight() {}

  Widget sideListContent() {
    return Expanded(flex: 2, child: ProgramsListView(programsBloc: programsBloc, textColor: overlaysTextColor));
  }

  @override
  void initState() {
    super.initState();
    _initProgramsBloc(widget.position);
    currentPos = widget.position;
    _initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    sendRecent(currentPos);
    programsBloc.dispose();
    orientation.allowAll();
  }

  @override
  Widget playerArea() {
    return _playerArea();
  }

  void _initProgramsBloc(int position) {
    setState(() {
      programsBloc?.dispose();
      programsBloc = ProgramsBloc(widget.channels[position]);
    });
  }

  void moveToPrevChannel() {
    sendRecent(currentPos);
    currentPos == 0 ? currentPos = widget.channels.length - 1 : currentPos--;
    _playChannel();
    _initProgramsBloc(currentPos);
  }

  void moveToNextChannel() {
    sendRecent(currentPos);
    currentPos == widget.channels.length - 1 ? currentPos = 0 : currentPos++;
    _playChannel();
    _initProgramsBloc(currentPos);
  }

  LiveStream currentChannel() {
    return widget.channels[currentPos];
  }

  void sendRecent(int recent) {
    final channel = widget.channels[recent];
    final now = DateTime.now();
    final msec = now.millisecondsSinceEpoch;
    channel.setRecentTime(msec);
    widget.stream.add(channel);
  }

  // private:

  final playerKey = GlobalKey();

  Widget bottomControls() {
    return BottomControls(
        programsBloc: programsBloc,
        buttons: <Widget>[
          PlayerButtons.previous(onPressed: () => moveToPrevChannel(), color: overlaysTextColor),
          createPlayPauseButton(),
          PlayerButtons.next(onPressed: () => moveToNextChannel(), color: overlaysTextColor),
          sideBarButton()
        ],
        textColor: overlaysTextColor,
        backgroundColor: backgroundColor?.withOpacity(overlaysOpacity));
  }

  Widget appBar() {
    final cur = currentChannel();
    return ChannelPageAppBar(
      backgroundColor: backgroundColor?.withOpacity(overlaysOpacity),
      textColor: overlaysTextColor,
      link: cur.primaryUrl(),
      title: AppLocalizations.toUtf8(cur.displayName()),
      onChromeCast: () => _callback(),
      actions: <Widget>[
        orientation.isPortrait(context)
            ? FullscreenButton.open(onTap: () {
                isVisiblePrograms = false;
                setTimerOverlays();
              })
            : FullscreenButton.close()
      ],
    );
  }

  void _callback() {
    if (!ChromeCastInfo().castConnected) {
      _initPlayer();
    }
    setState(() {});
  }

  void _initPlayer() {
    final cur = currentChannel();
    ChromeCastInfo().castConnected
        ? ChromeCastInfo().initVideo(cur.primaryUrl(), AppLocalizations.toUtf8(cur.displayName()))
        : _playerPage = StreamPlayerPage(channel: cur);
  }

  Widget chromeCastFiller() {
    final cur = currentChannel();
    return AspectRatio(aspectRatio: 16 / 9, child: ChromeCastFiller.live(cur.icon(), size: Size.square(128)));
  }

  Widget _playerArea() {
    return ChromeCastInfo().castConnected ? chromeCastFiller() : KeyedSubtree(key: playerKey, child: _playerPage);
  }

  void _playChannel() {
    final cur = currentChannel();
    ChromeCastInfo().castConnected
        ? ChromeCastInfo().initVideo(cur.primaryUrl(), AppLocalizations.toUtf8(cur.displayName()))
        : _playerPage.playChannel(cur);
  }
}
