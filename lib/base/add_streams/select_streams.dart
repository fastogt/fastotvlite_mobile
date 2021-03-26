import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/base/vods/constants.dart';
import 'package:fastotvlite/base/vods/vod_card_favorite_pos.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';
import 'package:flutter_fastotv_common/base/vods/vod_card.dart';

abstract class BaseSelectStreamPage<T extends StatefulWidget> extends State<T> {
  List<bool> checkValues = [];
  List<LiveStream> channels = [];
  List<VodStream> vods = [];
  List<FocusNode> nodes = [];
  int count;
  bool _hasTouch;

  StreamType type();

  String m3uText();

  Widget layout();

  @override
  void initState() {
    super.initState();
    _parseText();

    final device = locator<RuntimeDevice>();
    _hasTouch = device.hasTouch;
  }

  @override
  Widget build(BuildContext context) => layout();

  // private
  void _parseText() async {
    AddStreamResponse result = await M3UParser(m3uText(), type()).parseChannelsFromString();
    channels = result.channels;
    vods = result.vods;
    final current = selectedList();
    count = current.length;
    current.forEach((element) {
      if (!_hasTouch) {
        nodes.add(FocusNode());
      }
      checkValues.add(true);
    });
    if (mounted) {
      setState(() {});
    }
  }

  // public
  List selectedList() {
    return type() == StreamType.Live ? channels : vods;
  }

  void onSave() {
    List<LiveStream> outputLive = [];
    List<VodStream> outputVods = [];
    final current = selectedList();
    for (int i = 0; i < current.length; i++) {
      if (checkValues[i]) {
        type() == StreamType.Live ? outputLive.add(current[i]) : outputVods.add(current[i]);
      }
    }
    Navigator.of(context).pop(AddStreamResponse(type(), channels: outputLive, vods: outputVods));
  }

  void onBack() {
    Navigator.of(context).pop();
  }

  void onCheckBox(int index) {
    setState(() {
      checkValues[index] = !checkValues[index];
      checkValues[index] ? count++ : count--;
    });
  }
}

class LiveSelectTile extends StatelessWidget {
  final LiveStream channel;
  final bool value;
  final void Function() onCheckBox;

  LiveSelectTile(this.channel, this.value, this.onCheckBox);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        activeColor: Theme.of(context).accentColor,
        checkColor: Theming.of(context).onAccent(),
        secondary: PreviewIcon.live(channel.icon(), height: 40, width: 40),
        title: Text(AppLocalizations.toUtf8(channel.displayName())),
        value: value,
        onChanged: (value) => onCheckBox());
  }
}

class VodSelectCard extends StatelessWidget {
  final VodStream vod;
  final bool value;
  final void Function() onCheckBox;

  VodSelectCard(this.vod, this.value, this.onCheckBox);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      VodCard(
          iconLink: vod.icon(),
          duration: vod.duration(),
          interruptTime: vod.interruptTime(),
          width: CARD_WIDTH,
          onPressed: () {}),
      VodFavoriteButton(
          child: Checkbox(
              activeColor: Theme.of(context).accentColor,
              checkColor: Theming.of(context).onAccent(),
              value: value,
              onChanged: (value) => onCheckBox()))
    ]);
  }
}
