import 'package:fastotvlite/base/streams/live_bottom_controls.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:player/controller.dart';

const VOD_BOTTOM_CONTROL_HEIGHT = 4 + BUTTONS_LINE_HEIGHT + TIMELINE_HEIGHT;

class BasePlayerController<T extends IStream> extends PlayerController {
  int _currentUrl = 0;
  T stream;

  List<String> get urls => stream.urls;
  final Function? onPlay;

  BasePlayerController(this.stream, [this.onPlay]) : super(initLink: stream.urls[0]);

  @override
  String get currentLink => urls[_currentUrl];

  @override
  void onPlaying() {
    onPlay?.call();
  }

  void playStream(T stream) {
    this.stream = stream;
    setVideoLink(currentLink);
  }

  void sendRecent(T stream) async {
    final _timeManager = locator<TimeManager>();
    final msec = await _timeManager.realTime();
    stream.setRecentTime(msec);
  }
}

class LivePlayerController extends BasePlayerController<LiveStream> {
  double? initVolume;

  LivePlayerController(LiveStream stream, {this.initVolume}) : super(stream);

  @override
  void onPlaying() {
    if (initVolume != null) {
      setVolume(initVolume!);
    }
    super.onPlaying();
  }
}

class VodPlayerController extends BasePlayerController<VodStream> {
  VodPlayerController(VodStream stream) : super(stream);

  void setInterruptTime(int interruptTime) {
    stream.setInterruptTime(interruptTime);
  }
}
