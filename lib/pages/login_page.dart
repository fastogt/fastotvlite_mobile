import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/mobile/mobile_home.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/tv/tv_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/runtime_device.dart';

class LoginPageBuffer extends StatefulWidget {
  @override
  _LoginPageBufferState createState() => _LoginPageBufferState();
}

class _LoginPageBufferState extends State<LoginPageBuffer> {
  List<LiveStream> channels = [];
  List<VodStream> vods = [];
  bool _hasTouch;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    channels = settings.liveChannels();
    vods = settings.vods();
    final device = locator<RuntimeDevice>();
    _hasTouch = device.hasTouch;
  }

  @override
  Widget build(BuildContext context) {
    return _hasTouch ? HomePage(channels, vods) : HomeTV(channels, vods);
  }
}
