import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/player/controller.dart';
import 'package:fastotvlite/player/tv_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/utils.dart';

class TvLivePlayerPage extends StatefulWidget {
  final LiveStream channel;

  const TvLivePlayerPage(this.channel);

  @override
  _TvLivePlayerPageState createState() => _TvLivePlayerPageState();
}

class _TvLivePlayerPageState extends PlayerPageTVState<TvLivePlayerPage> {
  BasePlayerController<LiveStream> _controller;

  @override
  BasePlayerController<LiveStream> get controller => _controller;

  @override
  String get name => widget.channel.displayName();

  @override
  void initPlayer() {
    _controller = BasePlayerController<LiveStream>(widget.channel);
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
          Navigator.of(context).pop();
          return true;
        case MENU:
          toggleSnackBar(ctx);
          return true;
      }
      return false;
    });
  }
}
