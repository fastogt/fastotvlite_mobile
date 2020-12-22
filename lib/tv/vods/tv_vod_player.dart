import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/player/vod_player.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/tv/key_code.dart';

class TvVodPlayerPage extends StatefulWidget {
  final VodStream channel;

  TvVodPlayerPage(this.channel);

  void sendRecent() {
    final now = DateTime.now();
    channel.setRecentTime(now.millisecondsSinceEpoch);
  }

  void sendInterruptTime(int msec) {
    channel.setInterruptTime(msec);
  }

  @override
  _TvVodPlayerPageState createState() => _TvVodPlayerPageState();
}

class _TvVodPlayerPageState extends State<TvVodPlayerPage> {
  bool isVisible = true;
  VodPlayerPage _playerPage;
  FocusNode playerFocus = FocusNode();
  bool _isSnackBarActive = false;

  @override
  void initState() {
    super.initState();
    _playerPage = VodPlayerPage(channel: widget.channel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playerPage.playChannel(widget.channel);
      FocusScope.of(context).requestFocus(playerFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    final _scale = settings.screenScale();
    return FractionallySizedBox(
      widthFactor: _scale,
      heightFactor: _scale,
      child: Scaffold(
          body: Builder(
              builder: (context) => Focus(
                  onKey: (FocusNode node, RawKeyEvent event) => _onPlayer(event, context),
                  focusNode: playerFocus,
                  child: Container(child: _playerPage)))),
    );
  }

  // private:
  void _showSnackBar(BuildContext ctx, bool show) {
    if (show == _isSnackBarActive) {
      return;
    }

    if (show) {
      final contentColor = Theming.of(context).onBrightness();
      final snack = SnackBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white70,
          content: Container(
              child: Row(children: <Widget>[
            SizedBox(width: 32),
            Text(AppLocalizations.toUtf8(widget.channel.displayName()),
                style: TextStyle(fontSize: 36, color: contentColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false),
            Spacer(),
            Icon(_playerPage.isPlaying() ? Icons.pause : Icons.play_arrow, size: 48, color: contentColor)
          ])));
      _isSnackBarActive = true;
      Scaffold.of(ctx).showSnackBar(snack).closed.then((_) {
        _isSnackBarActive = false;
      });
    } else {
      Scaffold.of(ctx).hideCurrentSnackBar();
    }
  }

  bool _onPlayer(RawKeyEvent event, BuildContext ctx) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {

        /// Opens fullscreen player
        case ENTER:
        case KEY_CENTER:
        case PAUSE:
          if (_playerPage.isPlaying()) {
            _playerPage.pause();
          } else {
            _playerPage.play();
          }
          _showSnackBar(ctx, !_isSnackBarActive);
          break;

        case BACK:
        case BACKSPACE:
          widget.sendRecent();
          final interruptTime = _playerPage.interruptTime();
          widget.sendInterruptTime(interruptTime);
          Navigator.of(context).pop();
          break;
        case MENU:
          _showSnackBar(ctx, !_isSnackBarActive);
          break;

        case KEY_LEFT:
        case PREVIOUS:
          _playerPage.seekBackward(Duration(seconds: 5));
          break;
        case KEY_RIGHT:
        case NEXT:
          _playerPage.seekBackward(Duration(seconds: 5));
          break;

        default:
          break;
      }
      setState(() {});
    }
    return playerFocus.hasPrimaryFocus;
  }
}
