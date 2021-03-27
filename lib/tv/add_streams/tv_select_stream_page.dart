import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/base/add_streams/select_streams.dart';
import 'package:fastotvlite/base/vods/constants.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/utils.dart';

class SelectStreamTV extends StatefulWidget {
  final String m3uText;
  final StreamType type;

  const SelectStreamTV(this.m3uText, this.type);

  @override
  _SelectStreamTVState createState() => _SelectStreamTVState();
}

class _SelectStreamTVState extends BaseSelectStreamPage<SelectStreamTV> {
  final FocusNode _backButtonNode = FocusNode();
  final FocusNode _saveButtonNode = FocusNode();
  final FocusScopeNode _channelsScope = FocusScopeNode();
  double scale;

  @override
  String m3uText() => widget.m3uText;

  @override
  StreamType type() => widget.type;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    scale = settings.screenScale();
  }

  @override
  Widget layout() {
    final settings = locator<LocalStorageService>();
    scale = settings.screenScale();
    final primaryColor = Theme
        .of(context)
        .primaryColor;
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

    return FocusScope(
        node: _channelsScope,
        autofocus: true,
        child: FractionallySizedBox(
            widthFactor: scale,
            heightFactor: scale,
            child: Scaffold(
                appBar: AppBar(
                    leading: _backButton(),
                    actions: <Widget>[_saveButton()],
                    elevation: 0,
                    title: Text('Add',
                        style: TextStyle(color: backgroundColorBrightness(primaryColor))),
                    centerTitle: true),
                backgroundColor: primaryColor,
                body: _body())));
  }

  Color _buttonColor(FocusNode node) {
    return node.hasPrimaryFocus ? Theme
        .of(context)
        .accentColor : null;
  }

  Widget _backButton() {
    return Focus(
        autofocus: true,
        focusNode: _backButtonNode,
        onKey: _onAppBar,
        child: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 32,
            color: _buttonColor(_backButtonNode),
            onPressed: () => onBack()));
  }

  Widget _saveButton() {
    return Focus(
        focusNode: _saveButtonNode,
        onKey: _onAppBar,
        child: IconButton(
            icon: const Icon(Icons.save),
            iconSize: 32,
            color: _buttonColor(_saveButtonNode),
            onPressed: () => onSave()));
  }

  bool _onAppBar(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      final RawKeyDownEvent rawKeyDownEvent = event;
      final RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          if (_backButtonNode.hasPrimaryFocus) {
            onBack();
          } else if (_saveButtonNode.hasPrimaryFocus) {
            onSave();
          }
          break;

        case KEY_LEFT:
          _channelsScope.requestFocus(_backButtonNode);
          break;

        case KEY_RIGHT:
          _channelsScope.requestFocus(_saveButtonNode);
          break;

        case KEY_DOWN:
          _channelsScope.focusInDirection(TraversalDirection.down);
          break;

        default:
          break;
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  Widget _channelsList() {
    return Center(
        child: FractionallySizedBox(
            widthFactor: 0.4,
            child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  final channel = channels[index];
                  final node = nodes[index];
                  return Focus(
                      focusNode: node,
                      onKey: _onTile,
                      child: LiveSelectTile(channel, checkValues[index], () => onCheckBox(index)));
                })));
  }

  bool _onTile(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      final RawKeyDownEvent rawKeyDownEvent = event;
      final RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          onCheckBox(nodes.indexOf(node));
          break;

        case KEY_UP:
          if (nodes.indexOf(node) == 0) {
            _channelsScope.requestFocus(_backButtonNode);
          } else {
            _channelsScope.focusInDirection(TraversalDirection.up);
          }
          break;

        case KEY_DOWN:
          _channelsScope.focusInDirection(TraversalDirection.down);
          break;

        default:
          break;
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  Widget _cardList() {
    return Wrap(
        runSpacing: EDGE_INSETS,
        spacing: EDGE_INSETS,
        children: List<Widget>.generate(vods.length, (int index) {
          final node = nodes[index];
          return SizedBox(
              width: CARD_WIDTH + BORDER_WIDTH,
              child: Focus(
                  onKey: _onCard,
                  focusNode: node,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: node.hasFocus ? Colors.amber : Colors.transparent,
                              width: BORDER_WIDTH)),
                      child: VodSelectCard(
                          vods[index], checkValues[index], () => onCheckBox(index)))));
        }));
  }

  bool _onCard(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      final RawKeyDownEvent rawKeyDownEvent = event;
      final RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          onCheckBox(nodes.indexOf(node));
          break;

      /// Moves around cards
        case KEY_LEFT:
          if (_channelsScope.focusedChild.offset.dx > CARD_WIDTH) {
            _channelsScope.focusInDirection(TraversalDirection.left);
          } else {
            _channelsScope.focusInDirection(TraversalDirection.up);
            while (MediaQuery
                .of(context)
                .size
                .width - _channelsScope.focusedChild.offset.dx >
                CARD_WIDTH * 2) {
              _channelsScope.focusInDirection(TraversalDirection.right);
            }
          }
          break;

        case KEY_RIGHT:
          if (MediaQuery
              .of(context)
              .size
              .width - _channelsScope.focusedChild.offset.dx >
              CARD_WIDTH * 2) {
            _channelsScope.focusInDirection(TraversalDirection.right);
          } else {
            while (_channelsScope.focusedChild.offset.dx > CARD_WIDTH) {
              _channelsScope.focusInDirection(TraversalDirection.left);
            }
            _channelsScope.focusInDirection(TraversalDirection.down);
          }
          break;

        case KEY_UP:
          if (nodes.indexOf(node) < 6) {
            FocusScope.of(context).requestFocus(_backButtonNode);
          } else {
            _channelsScope.focusInDirection(TraversalDirection.up);
          }
          break;

        case KEY_DOWN:
          _channelsScope.focusInDirection(TraversalDirection.down);
          break;

        default:
          break;
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }
}
