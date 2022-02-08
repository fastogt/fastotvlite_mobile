import 'dart:async';

import 'package:dart_chromecast/chromecast.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/chromecast_filler.dart';
import 'package:player/common/states.dart';
import 'package:player/controller.dart';
import 'package:player/widgets/player.dart';
import 'package:player/widgets/timeline.dart';

abstract class PlayerPageMobileState<T extends StatefulWidget> extends State<T> {
  final GlobalKey _playerKey = GlobalKey();

  PlayerController get controller;

  IStream get stream;

  bool get castConnected => ChromeCastInfo().castConnected;
  late StreamSubscription<bool> _ccConnection;
  bool? _ccConnected;

  bool get initizalied => _ccConnected != null;

  @override
  void initState() {
    super.initState();
    _ccConnection = ChromeCastInfo().castConnectedStream.listen((event) {
      if (event) {
        _initChromeCast(stream.primaryUrl(), stream.displayName());
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          controller.dispose();
        });
      } else {
        initPlayer();
      }
      if (mounted && _ccConnected != event) {
        setState(() {
          _ccConnected = event;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ccConnection.cancel();
    controller.dispose();
  }

  bool isPlaying() {
    if (castConnected) {
      return ChromeCastInfo().isPlaying();
    }
    return controller.isPlaying();
  }

  void play() {
    if (castConnected) {
      ChromeCastInfo().play();
    } else {
      controller.play();
    }
    setState(() {});
  }

  void pause() {
    if (castConnected) {
      ChromeCastInfo().pause();
    } else {
      controller.pause();
    }
    setState(() {});
  }

  void onLongTapLeft() {
    if (!castConnected) {
      controller.seekBackward();
    }
  }

  void onLongTapRight() {
    if (!castConnected) {
      controller.seekForward();
    }
  }

  Widget playerArea(String icon) {
    if (!initizalied) {
      return const AspectRatio(
          aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
    }
    final cc = _ccConnected != null && _ccConnected == true;
    return cc
        ? AspectRatio(aspectRatio: 16 / 9, child: _chromeCastFiller(icon))
        : LitePlayer(key: _playerKey, controller: controller);
  }

  Widget createPlayPauseButton(Color color) {
    final placeholder = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.play_arrow, color: color.withOpacity(0.5)));
    if (!initizalied) {
      return placeholder;
    } else if (castConnected) {
      return _playPause(color);
    } else {
      return PlayerStateListener(controller, builder: (context) {
        return _playPause(color);
      }, placeholder: placeholder);
    }
  }

  Widget _playPause(Color color) {
    if (isPlaying()) {
      return PlayerButtons.pause(onPressed: pause, color: color);
    } else {
      return PlayerButtons.play(onPressed: play, color: color);
    }
  }

  Widget timeLine() {
    return ChromeCastInfo().castConnected ? const SizedBox() : LitePlayerTimeline(controller);
  }

  Widget _chromeCastFiller(String icon) {
    return ChromeCastFiller.live(icon, size: Size.square(MediaQuery.of(context).size.height));
  }

  void initPlayer();

  void _initChromeCast(String link, String name) {
    ChromeCastInfo().initVideo(link, AppLocalizations.toUtf8(name));
  }
}
