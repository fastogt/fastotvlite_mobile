import 'package:fastotvlite/base/streams/live_bottom_controls.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/player/common_player.dart';
import 'package:fastotvlite/player/vod_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/player_buttons.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/screen_orientation.dart' as orientation;
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_filler.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';

class VodPlayer extends StatefulWidget {
  final VodStream channel;

  VodPlayer(this.channel);

  @override
  VodPlayerPageMobileState createState() {
    return VodPlayerPageMobileState(this.channel);
  }
}

class VodPlayerPageMobileState extends AppBarPlayerVod<VodPlayer> {
  VodPlayerPageMobileState(VodStream channel);

  static const Duration SEEK_DURATION = Duration(seconds: 5);
  static const BOTTOM_CONTROL_HEIGHT = 4 + BUTTONS_LINE_HEIGHT + TIMELINE_HEIGHT;

  VodPlayerPage _vodPlayerPage;

  double bottomControlsHeight() => BOTTOM_CONTROL_HEIGHT;

  bool isPlaying() {
    if (ChromeCastInfo().castConnected) {
      return ChromeCastInfo().isPlaying();
    } else {
      return _vodPlayerPage.isPlaying();
    }
  }

  void play() => _vodPlayerPage.play();

  void pause() => _vodPlayerPage.pause();

  void onLongTapLeft() => _vodPlayerPage.seekBackward(SEEK_DURATION);

  void onLongTapRight() => _vodPlayerPage.seekForward(SEEK_DURATION);

  final playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    orientation.onlyLandscape();
    _initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    orientation.allowAll();
  }

  Widget appBar() {
    return ChannelPageAppBar(
        link: widget.channel.primaryUrl(),
        title: AppLocalizations.toUtf8(widget.channel.displayName()),
        backgroundColor: backgroundColor.withOpacity(overlaysOpacity),
        textColor: overlaysTextColor,
        onChromeCast: () => callback(),
        onExit: position());
  }

  int position() {
    if (ChromeCastInfo().castConnected) {
      return ChromeCastInfo().position()?.toInt();
    } else {
      return _vodPlayerPage.position().inMilliseconds;
    }
  }

  void callback() {
    if (!ChromeCastInfo().castConnected) {
      _vodPlayerPage = VodPlayerPage(channel: widget.channel);
    }
    setState(() {});
  }

  Widget timeLine() {
    return ChromeCastInfo().castConnected ? SizedBox() : _vodPlayerPage.timeLine();
  }

  @override
  Widget playerArea() => _playerArea();

  Widget _playerArea() {
    return ChromeCastInfo().castConnected ? chromeCastFiller() : KeyedSubtree(key: playerKey, child: _vodPlayerPage);
  }

  Widget chromeCastFiller() =>
      ChromeCastFiller.vod(widget.channel.previewIcon(), size: Size.square(MediaQuery.of(context).size.height));

  Widget bottomControls() {
    return Container(
        color: backgroundColor.withOpacity(overlaysOpacity),
        width: MediaQuery.of(context).size.width,
        height: BOTTOM_CONTROL_HEIGHT + MediaQuery.of(context).padding.top,
        child: Stack(children: <Widget>[
          timeLine(),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Spacer(),
                PlayerButtons.seekBackward(
                    onPressed: () => _vodPlayerPage.seekBackward(SEEK_DURATION), color: overlaysTextColor),
                SizedBox(width: 16),
                createPlayPauseButton(),
                SizedBox(width: 16),
                PlayerButtons.seekForward(
                    onPressed: () => _vodPlayerPage.seekForward(SEEK_DURATION), color: overlaysTextColor),
                Spacer()
              ]))
        ]));
  }

  void _initPlayer() {
    ChromeCastInfo().castConnected
        ? ChromeCastInfo().initVideo(widget.channel.primaryUrl(), AppLocalizations.toUtf8(widget.channel.displayName()))
        : _vodPlayerPage = VodPlayerPage(channel: widget.channel);
  }
}
