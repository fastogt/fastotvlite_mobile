import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/base/add_streams/select_streams.dart';
import 'package:fastotvlite/base/vods/constants.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/wrap.dart';

class ChannelsPreviewPage extends StatefulWidget {
  final String m3uText;
  final StreamType type;

  ChannelsPreviewPage(this.m3uText, this.type);

  @override
  _ChannelsPreviewPageState createState() => _ChannelsPreviewPageState();
}

class _ChannelsPreviewPageState extends BaseSelectStreamPage<ChannelsPreviewPage> {
  StreamType type() => widget.type;

  String m3uText() => widget.m3uText;

  Widget layout() {
    final primaryColor = Theme.of(context).primaryColor;
    final appBarTextColor = Theming.of(context).onCustomColor(primaryColor);
    final current = selectedList();

    Widget _body() {
      if (current.isEmpty) {
        return CircularProgressIndicator();
      }

      switch (widget.type) {
        case StreamType.Live:
          return _channelsList();
        case StreamType.Vod:
          return _cardList();
        default:
          return CircularProgressIndicator();
      }
    }

    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: appBarTextColor),
            title: Text('Add channels ' + '($count/${current.length})', style: TextStyle(color: appBarTextColor))),
        body: _body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _floatingButton());
  }

  Widget _floatingButton() {
    final accentColor = Theme.of(context).accentColor;
    final textColor = Theming.of(context).onCustomColor(accentColor);
    return RaisedButton(
        onPressed: () => onSave(),
        child: Container(height: 48, child: Center(child: Text('Add selected', style: TextStyle(fontSize: 16)))),
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
    return CustomWrap(
        width: MediaQuery.of(context).size.width,
        itemWidth: CARD_WIDTH + BORDER_WIDTH,
        horizontalPadding: EDGE_INSETS,
        verticalPadding: EDGE_INSETS,
        children: List<Widget>.generate(vods.length, (int index) {
          return VodSelectCard(vods[index], checkValues[index], () => onCheckBox(index));
        }));
  }
}
