import 'package:fastotvlite/player/controller.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/player_buttons.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/appbar_player.dart';
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_filler.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';
import 'package:player/common/states.dart';
import 'package:player/controller.dart';
import 'package:player/widgets/player.dart';
import 'package:player/widgets/timeline.dart';

class VodTrailer extends StatefulWidget {
  final String title;
  final String link;
  final String imageLink;

  const VodTrailer(this.title, this.link, this.imageLink);

  @override
  VodTrailerPageMobileState createState() {
    return VodTrailerPageMobileState();
  }
}

class VodTrailerPageMobileState extends State<VodTrailer> {
  PlayerController _controller;

  bool get _castConnected => ChromeCastInfo().castConnected;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    return AppBarPlayer(
        appbar: (_, background, text) => appBar(),
        child: (_) => playerArea(),
        bottomControls: (_, background, text, __) => bottomControls(),
        bottomControlsHeight: VOD_BOTTOM_CONTROL_HEIGHT,
        onDoubleTap: () {
          if (isPlaying()) {
            pause();
          } else {
            play();
          }
        },
        onLongTapLeft: onLongTapLeft,
        onLongTapRight: onLongTapRight,
        absoulteBrightness: settings.brightnessChange(),
        absoulteSound: settings.soundChange());
  }

  bool isPlaying() {
    if (_castConnected) {
      return ChromeCastInfo().isPlaying();
    }
    return _controller.isPlaying();
  }

  void play() {
    if (_castConnected) {
      ChromeCastInfo().play();
    } else {
      _controller.play();
    }
  }

  void pause() {
    if (_castConnected) {
      ChromeCastInfo().pause();
    } else {
      _controller.pause();
    }
  }

  void onLongTapLeft() {
    if (!_castConnected) {
      _controller.seekBackward();
    }
  }

  void onLongTapRight() {
    if (!_castConnected) {
      _controller.seekForward();
    }
  }

  Widget appBar() {
    return ChannelPageAppBar(
        link: widget.link,
        title: widget.title,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        onChromeCast: _chromeCastCallback);
  }

  Widget bottomControls() {
    return Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: VOD_BOTTOM_CONTROL_HEIGHT + MediaQuery.of(context).padding.top,
        child: Stack(children: <Widget>[
          Align(alignment: Alignment.topCenter, child: _timeLine()),
          Padding(padding: const EdgeInsets.all(16.0), child: _controls())
        ]));
  }

  Widget playerArea() {
    return ChromeCastInfo().castConnected
        ? _chromeCastFiller()
        : LitePlayer(controller: _controller);
  }

  Widget _controls() {
    return PlayerStateListener(_controller, builder: (_) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        if (!_castConnected)
          PlayerButtons.seekBackward(onPressed: _controller.seekBackward, color: Colors.white),
        const SizedBox(width: 16),
        createPlayPauseButton(),
        const SizedBox(width: 16),
        if (!_castConnected)
          PlayerButtons.seekForward(onPressed: _controller.seekForward, color: Colors.white)
      ]);
    }, placeholder: const SizedBox());
  }

  Widget createPlayPauseButton() {
    if (isPlaying()) {
      return PlayerButtons.pause(onPressed: pause, color: Colors.white);
    } else {
      return PlayerButtons.play(onPressed: play, color: Colors.white);
    }
  }

  Widget _timeLine() {
    return ChromeCastInfo().castConnected ? const SizedBox() : LitePlayerTimeline(_controller);
  }

  Widget _chromeCastFiller() {
    return ChromeCastFiller.vod(widget.imageLink,
        size: Size.square(MediaQuery.of(context).size.height));
  }

  void _chromeCastCallback() {
    if (_castConnected) {
      _controller.dispose();
      ChromeCastInfo().initVideo(widget.link, AppLocalizations.toUtf8(widget.title));
    } else {
      _controller = PlayerController(initLink: widget.link);
    }
    setState(() {});
  }

  void _initPlayer() {
    ChromeCastInfo().castConnected
        ? ChromeCastInfo().initVideo(widget.link, AppLocalizations.toUtf8(widget.title))
        : _controller = PlayerController(initLink: widget.link);
  }
}
