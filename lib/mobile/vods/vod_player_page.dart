import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/player/controller.dart';
import 'package:fastotvlite/player/mobile_player.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/player_buttons.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/appbar_player.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';
import 'package:player/common/states.dart';

class VodPlayer extends StatefulWidget {
  final VodStream channel;

  const VodPlayer(this.channel);

  @override
  VodPlayerPageMobileState createState() {
    return VodPlayerPageMobileState();
  }
}

class VodPlayerPageMobileState extends PlayerPageMobileState<VodPlayer> {
  VodPlayerController _controller;

  @override
  VodPlayerController get controller => _controller;

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    final player = playerArea(widget.channel.icon());
    return AppBarPlayer(
        appbar: (_, background, text) => appBar(),
        child: (_) => player,
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

  Widget appBar() {
    return ChannelPageAppBar(
        link: widget.channel.primaryUrl(),
        title: AppLocalizations.toUtf8(widget.channel.displayName()),
        backgroundColor: Colors.black,
        textColor: Colors.white,
        onExit: () {
          controller.sendRecent(widget.channel);
          controller.setInterruptTime(position());
          Navigator.of(context).pop();
        },
        onChromeCast: () {
          chromeCastCallback(widget.channel.primaryUrl(), widget.channel.displayName());
        });
  }

  Widget bottomControls() {
    return Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: VOD_BOTTOM_CONTROL_HEIGHT + MediaQuery.of(context).padding.top,
        child: Stack(children: <Widget>[
          Align(alignment: Alignment.topCenter, child: timeLine()),
          Padding(padding: const EdgeInsets.all(16.0), child: _controls(Colors.white))
        ]));
  }

  Widget _controls(Color color) {
    return PlayerStateListener(controller, builder: (_) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        if (!castConnected)
          PlayerButtons.seekBackward(onPressed: controller.seekBackward, color: color),
        const SizedBox(width: 16),
        createPlayPauseButton(color),
        const SizedBox(width: 16),
        if (!castConnected)
          PlayerButtons.seekForward(onPressed: controller.seekForward, color: color)
      ]);
    }, placeholder: const SizedBox());
  }

  int position() {
    if (ChromeCastInfo().castConnected) {
      return ChromeCastInfo().position()?.toInt();
    }
    return controller.position().inMilliseconds;
  }

  @override
  void initPlayer() {
    _controller = VodPlayerController(widget.channel);
  }
}
