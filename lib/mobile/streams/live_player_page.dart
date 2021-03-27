import 'dart:async';
import 'dart:core';
import 'package:dart_chromecast/widgets/connection_icon.dart';
import 'package:fastotvlite/player/mobile_player.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/base/streams/live_bottom_controls.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/base/streams/programs_list.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/player/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/appbar_player.dart';
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/base/controls/fullscreen_button.dart';
import 'package:dart_chromecast/chromecast.dart';
import 'package:player/common/states.dart';

class ChannelPage extends StatefulWidget {
  final List<LiveStream> channels;
  final int position;
  final void Function(LiveStream stream) addRecent;

  const ChannelPage({this.channels, this.position, this.addRecent});

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends PlayerPageMobileState<ChannelPage> {
  LivePlayerController _controller;

  @override
  LiveStream get stream => _currentChannel;

  @override
  LivePlayerController get controller => _controller;

  ProgramsBloc programsBloc;
  int currentPos;

  LiveStream get _currentChannel => widget.channels[currentPos];

  @override
  void initState() {
    _initProgramsBloc(widget.position);
    currentPos = widget.position;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    programsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    return WillPopScope(
        onWillPop: () {
          _sendRecent();
          Navigator.of(context).pop(currentPos);
          return Future.value(true);
        },
        child: AppBarPlayer.sideList(
            appbar: appBar,
            child: playerArea(_currentChannel.icon()),
            bottomControls: bottomControls,
            sideList: sideListContent,
            bottomControlsHeight: bottomControlsHeight(),
            onDoubleTap: () {
              if (isPlaying()) {
                pause();
              } else {
                play();
              }
            },
            absoulteBrightness: settings.brightnessChange(),
            absoulteSound: settings.soundChange()));
  }

  double bottomControlsHeight() {
    if (programsBloc.currentProgramIndex >= 0) {
      return 4 + BUTTONS_LINE_HEIGHT + TEXT_HEIGHT + TIMELINE_HEIGHT + TEXT_PADDING + 16;
    } else {
      return 4 + BUTTONS_LINE_HEIGHT;
    }
  }

  Widget appBar(Color back, Color text) {
    return ChannelPageAppBar(
        backgroundColor: back,
        textColor: text,
        title: AppLocalizations.toUtf8(_currentChannel.displayName()),
        onExit: () {
          _sendRecent();
          Navigator.of(context).pop();
        },
        actions: <Widget>[
          if (isPortrait(context))
            const FullscreenButton.open()
          else
            const FullscreenButton.close(),
          const ChromeCastIcon()
        ]);
  }

  Widget bottomControls(Color back, Color text, Widget sideListButton) {
    return Container(
        color: back ?? Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        height: bottomControlsHeight(),
        child: _controls(back, text, sideListButton));
  }

  Widget sideListContent(Color text) {
    return ProgramsListView(programsBloc: programsBloc, textColor: text);
  }

  Widget _controls(Color back, Color text, Widget sideListButton) {
    return BottomControls(
        programsBloc: programsBloc,
        buttons: <Widget>[
          PlayerButtons.previous(onPressed: _moveToPrevChannel, color: text),
          _playPause(text),
          PlayerButtons.next(onPressed: _moveToNextChannel, color: text),
          sideListButton
        ],
        textColor: text,
        backgroundColor: back);
  }

  Widget _playPause(Color text) {
    return PlayerStateListener(controller, builder: (context) {
      return createPlayPauseButton(text);
    },
        placeholder: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.play_arrow, color: text.withOpacity(0.5))));
  }

  void _moveToPrevChannel() {
    _sendRecent();
    currentPos == 0 ? currentPos = widget.channels.length - 1 : currentPos--;
    _playChannel();
    _initProgramsBloc(currentPos);
  }

  void _moveToNextChannel() {
    _sendRecent();
    currentPos == widget.channels.length - 1 ? currentPos = 0 : currentPos++;
    _playChannel();
    _initProgramsBloc(currentPos);
  }

  void _sendRecent() {
    _controller.sendRecent(_currentChannel);
    widget.addRecent(_currentChannel);
  }

  void _initProgramsBloc(int position) {
    setState(() {
      programsBloc?.dispose();
      programsBloc = ProgramsBloc(widget.channels[position]);
    });
  }

  void _playChannel() {
    if (castConnected) {
      ChromeCastInfo().initVideo(
          _currentChannel.primaryUrl(), AppLocalizations.toUtf8(_currentChannel.displayName()));
    } else {
      _controller.playStream(_currentChannel);
    }
    setState(() {});
  }

  @override
  void initPlayer() {
    _controller = LivePlayerController(_currentChannel);
  }
}
