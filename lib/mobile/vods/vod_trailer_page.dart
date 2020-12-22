import 'package:fastotvlite/base/streams/live_bottom_controls.dart';
import 'package:fastotvlite/player/common_player.dart';
import 'package:fastotvlite/player/vod_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/player_buttons.dart';
import 'package:flutter_common/screen_orientation.dart' as orientation;
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_filler.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';

class VodTrailer extends StatefulWidget {
  final String title;
  final String link;
  final String imageLink;

  VodTrailer(this.title, this.link, this.imageLink);

  @override
  VodTrailerPageMobileState createState() {
    return VodTrailerPageMobileState(this.title, this.link);
  }
}

class VodTrailerPageMobileState extends AppBarPlayerVod<VodTrailer> {
  VodTrailerPageMobileState(String title, String link);

  static const Duration SEEK_DURATION = Duration(seconds: 5);
  static const BOTTOM_CONTROL_HEIGHT = 4 + BUTTONS_LINE_HEIGHT + TIMELINE_HEIGHT;

  TrailerPlayerPage _vodPlayerPage;

  double bottomControlsHeight() => BOTTOM_CONTROL_HEIGHT;

  bool isPlaying() => _vodPlayerPage.isPlaying();

  void play() => _vodPlayerPage.play();

  void pause() => _vodPlayerPage.pause();

  void onLongTapLeft() => _vodPlayerPage.seekBackward(SEEK_DURATION);

  void onLongTapRight() => _vodPlayerPage.seekForward(SEEK_DURATION);

  @override
  void initState() {
    super.initState();
    orientation.onlyLandscape();
    _vodPlayerPage = TrailerPlayerPage(widget.link);
  }

  @override
  void dispose() {
    super.dispose();
    orientation.allowAll();
  }

  Widget appBar() {
    return ChannelPageAppBar(
        link: widget.link,
        title: widget.title,
        backgroundColor: backgroundColor.withOpacity(overlaysOpacity),
        textColor: overlaysTextColor,
        onChromeCast: () => callback());
  }

  void callback() {
    if (!ChromeCastInfo().castConnected) {
      _vodPlayerPage = TrailerPlayerPage(widget.link);
    }
    setState(() {});
  }

  Widget timeLine() {
    return ChromeCastInfo().castConnected ? SizedBox() : _vodPlayerPage.timeLine();
  }

  @override
  Widget playerArea() => ChromeCastInfo().castConnected ? chromeCastFiller() : _vodPlayerPage;

  Widget chromeCastFiller() =>
      ChromeCastFiller.vod(widget.imageLink, size: Size.square(MediaQuery.of(context).size.height));

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
}
