import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/player_buttons.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_filler.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';
import 'package:player/controller.dart';
import 'package:player/widgets/player.dart';
import 'package:player/widgets/timeline.dart';

abstract class PlayerPageMobileState<T extends StatefulWidget> extends State<T> {
  final GlobalKey _playerKey = GlobalKey();
  PlayerController get controller;

  bool get castConnected => ChromeCastInfo().castConnected;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
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
    return ChromeCastInfo().castConnected
        ? _chromeCastFiller(icon)
        : LitePlayer(key: _playerKey, controller: controller);
  }

  Widget createPlayPauseButton(Color color) {
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

  void chromeCastCallback(String link, String name) {
    if (castConnected) {
      controller.dispose();
      _initChromeCast(link, name);
    } else {
      initPlayer();
    }
    setState(() {});
  }

  void initPlayer();

  void _initChromeCast(String link, String name) {
    ChromeCastInfo().initVideo(link, AppLocalizations.toUtf8(name));
  }
}
