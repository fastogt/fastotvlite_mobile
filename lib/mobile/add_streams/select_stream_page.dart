import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/base/add_streams/select_streams.dart';
import 'package:fastotvlite/base/vods/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';

class ChannelsPreviewPage extends StatefulWidget {
  final String m3uText;
  final StreamType type;

  const ChannelsPreviewPage(this.m3uText, this.type);

  @override
  _ChannelsPreviewPageState createState() => _ChannelsPreviewPageState();
}

class _ChannelsPreviewPageState extends BaseSelectStreamPage<ChannelsPreviewPage> {
  @override
  StreamType type() => widget.type;

  @override
  String m3uText() => widget.m3uText;

  @override
  Widget layout() {
    final primaryColor = Theme.of(context).primaryColor;
    final appBarTextColor = backgroundColorBrightness(primaryColor);
    final current = selectedList();

    Widget _body() {
      if (current.isEmpty) {
        return const CircularProgressIndicator();
      }

      switch (widget.type) {
        case StreamType.Live:
          return _channelsList();
        case StreamType.Vod:
          return _cardList();
        default:
          return const CircularProgressIndicator();
      }
    }

    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: appBarTextColor),
            title: Text('Add channels ' + '($count/${current.length})',
                style: TextStyle(color: appBarTextColor))),
        body: _body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _floatingButton());
  }

  Widget _floatingButton() {
    final accentColor = Theme.of(context).accentColor;
    final textColor = backgroundColorBrightness(accentColor);
    return RaisedButton(
        onPressed: () => onSave(),
        child: const SizedBox(
            height: 48, child: Center(child: Text('Add selected', style: TextStyle(fontSize: 16)))),
        color: accentColor,
        textColor: textColor);
  }

  Widget _channelsList() {
    return ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return LiveSelectTile(channels[index], checkValues[index], () => onCheckBox(index));
        });
  }

  Widget _cardList() {
    return Wrap(
        runSpacing: EDGE_INSETS,
        spacing: EDGE_INSETS,
        children: List<Widget>.generate(vods.length, (int index) {
          return SizedBox(
              width: CARD_WIDTH + BORDER_WIDTH,
              child: VodSelectCard(vods[index], checkValues[index], () => onCheckBox(index)));
        }));
  }
}
