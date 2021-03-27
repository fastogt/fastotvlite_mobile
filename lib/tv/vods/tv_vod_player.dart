import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/player/controller.dart';
import 'package:fastotvlite/player/tv_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/utils.dart';

class TvVodPlayerPage extends StatefulWidget {
  final VodStream channel;

  const TvVodPlayerPage(this.channel);

  @override
  _TvVodPlayerPageState createState() {
    return _TvVodPlayerPageState();
  }
}

class _TvVodPlayerPageState extends PlayerPageTVState<TvVodPlayerPage> {
  VodPlayerController _controller;

  @override
  VodPlayerController get controller => _controller;

  @override
  String get name => widget.channel.displayName();

  @override
  void initPlayer() {
    _controller = VodPlayerController(widget.channel);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  bool onPlayer(RawKeyEvent event, BuildContext ctx) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case ENTER:
        case KEY_CENTER:
        case PAUSE:
          if (_controller.isPlaying()) {
            _controller.pause();
          } else {
            _controller.play();
          }
          toggleSnackBar(ctx);
          return true;

        case BACK:
        case BACKSPACE:
          _controller.sendRecent(widget.channel);
          _controller.setInterruptTime(_controller
              .position()
              .inMilliseconds);
          Navigator.of(context).pop();
          return true;
        case MENU:
          toggleSnackBar(ctx);
          return true;

        case KEY_LEFT:
        case PREVIOUS:
          _controller.seekBackward();
          return true;
        case KEY_RIGHT:
        case NEXT:
          _controller.seekBackward();
          return true;
      }
      return false;
    });
  }
}
