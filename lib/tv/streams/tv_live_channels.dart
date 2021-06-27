import 'package:fastotvlite/bloc/live_bloc.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

class ChannelsListTV extends StatefulWidget {
  final Size size;
  final LiveStreamBlocTV bloc;
  final CustomScrollController scrollController;
  final FocusNode focus;
  final void Function() setEpg;
  final KeyEventResult Function(FocusNode node, RawKeyEvent event, int index) onChannels;

  const ChannelsListTV(
      {this.bloc, this.size, this.onChannels, this.focus, this.scrollController, this.setEpg});

  @override
  ChannelsListTVState createState() => ChannelsListTVState();
}

class ChannelsListTVState extends State<ChannelsListTV> {
  static const LIST_HEADER_SIZE = 32.0;

  Color _color;

  List<String> get _categories => widget.bloc.categories;

  String get _currentCategory => widget.bloc.category;

  Map<String, List<LiveStream>> get channelsMap => widget.bloc.streamsMap;

  List<LiveStream> get _currentChannels => channelsMap[_currentCategory];

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focus.removeListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[_categoryTitle(), const Divider(height: 0.0), channelsList()]);
  }

  // categody
  Widget _categoryTitle() {
    final _size = Size(widget.size.width, LIST_HEADER_SIZE);
    return Focus(
        focusNode: widget.focus,
        onKey: _onCategory,
        child: SizedBox(
            width: _size.width,
            height: _size.height,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Icon(Icons.keyboard_arrow_left, color: _color ?? Theme.of(context).disabledColor),
              Text(_title(_currentCategory)),
              Icon(Icons.keyboard_arrow_right, color: _color ?? Theme.of(context).disabledColor)
            ])));
  }

  void _onFocusChange() {
    setState(() {
      if (widget.focus.hasFocus) {
        _color = Theme.of(context).colorScheme.secondary;
      } else {
        _color = Theme.of(context).disabledColor;
      }
    });
  }

  String _title(String title) {
    if (title == TR_ALL || title == TR_RECENT || title == TR_FAVORITE) {
      return AppLocalizations.of(context).translate(title);
    }
    return AppLocalizations.toUtf8(title);
  }

  KeyEventResult _onCategory(FocusNode node, RawKeyEvent event) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case BACK:
        case BACKSPACE:
        case KEY_UP:
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          return KeyEventResult.handled;

        case ENTER:
        case KEY_CENTER:
        case KEY_DOWN:
          widget.setEpg();
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          return KeyEventResult.handled;

        case KEY_RIGHT:
          int _cur = _categories.indexOf(_currentCategory);
          if (_cur == _categories.length - 1) {
            _cur = 0;
          } else {
            _cur++;
          }
          widget.bloc.setCategory(_categories[_cur]);
          if (_categories[_cur] == TR_RECENT) {
            widget.bloc.sortRecent();
          }
          if (widget.scrollController.controller.hasClients) {
            widget.scrollController.moveToTop();
          }
          setState(() {});
          return KeyEventResult.handled;

        case KEY_LEFT:
          int _cur = _categories.indexOf(_currentCategory);
          if (_cur == 0) {
            _cur = _categories.length - 1;
          } else {
            _cur--;
          }
          widget.bloc.setCategory(_categories[_cur]);
          if (_categories[_cur] == TR_RECENT) {
            widget.bloc.sortRecent();
          }
          if (widget.scrollController.controller.hasClients) {
            widget.scrollController.moveToTop();
          }
          setState(() {});
          return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }

  // channels
  Widget channelsList() {
    final _size = Size(widget.size.width, widget.size.height - LIST_HEADER_SIZE);
    if (_currentCategory == TR_FAVORITE && channelsMap[TR_FAVORITE].isEmpty) {
      return _NoChannels.favorite(_size);
    } else if (_currentCategory == TR_RECENT && channelsMap[TR_RECENT].isEmpty) {
      return _NoChannels.recent(_size);
    }
    return _ChannelsList(
        onKey: widget.onChannels,
        channels: _currentChannels,
        scrollController: widget.scrollController.controller,
        itemHeight: widget.scrollController.itemHeight,
        size: _size);
  }
}

class _ChannelsList extends StatelessWidget {
  final List<LiveStream> channels;
  final ScrollController scrollController;
  final Size size;
  final double itemHeight;
  final KeyEventResult Function(FocusNode node, RawKeyEvent event, int index) onKey;

  const _ChannelsList(
      {@required this.channels,
      this.scrollController,
      @required this.onKey,
      this.itemHeight,
      @required this.size});

  @override
  Widget build(BuildContext context) {
    final _itemHeight = itemHeight ?? 64;
    return SizedBox(
        width: size.width,
        height: size.height,
        child: ListView.builder(
            controller: scrollController,
            itemCount: channels.length,
            itemExtent: _itemHeight,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return _ChannelTile(
                  channel: channel,
                  onKey: (node, event) => onKey(node, event, index),
                  itemHeight: _itemHeight);
            }));
  }
}

class _ChannelTile extends StatefulWidget {
  final LiveStream channel;
  final double itemHeight;
  final KeyEventResult Function(FocusNode node, RawKeyEvent event) onKey;

  const _ChannelTile({@required this.channel, @required this.onKey, this.itemHeight});

  @override
  _ChannelTileState createState() => _ChannelTileState();
}

class _ChannelTileState extends State<_ChannelTile> {
  static const Size CHANNEL_AVATAR_SIZE = Size(40.0, 40.0);

  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: _node,
        onKey: widget.onKey,
        child: Stack(children: <Widget>[_background(), _tile()]));
  }

  // private:
  Widget _background() {
    return Container(color: _backgroundColor());
  }

  Widget _tile() {
    return ListTile(
        leading: _channelAvatar(widget.channel),
        title: Text(AppLocalizations.toUtf8(widget.channel.displayName()),
            style: TextStyle(fontSize: widget.itemHeight / 4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis));
  }

  Widget _channelAvatar(LiveStream channel) {
    return PreviewIcon.live(channel.icon(),
        height: CHANNEL_AVATAR_SIZE.height, width: CHANNEL_AVATAR_SIZE.width);
  }

  Color _backgroundColor() {
    if (!_node.hasFocus) {
      return Colors.transparent;
    }

    return Theme.of(context).focusColor;
  }

  void _onFocusChange() {
    setState(() {});
  }
}

enum NoChannelsType { FAVORITE, RECENT }

class _NoChannels extends StatelessWidget {
  final NoChannelsType type;
  final Size size;

  const _NoChannels.favorite(this.size) : type = NoChannelsType.FAVORITE;

  const _NoChannels.recent(this.size) : type = NoChannelsType.RECENT;

  @override
  Widget build(BuildContext context) {
    final child = NonAvailableBuffer(iconSize: 48, icon: _typeIcon(), message: _typeMessage());
    return SizedBox(height: size.height, width: size.width, child: Center(child: child));
  }

  // private:
  IconData _typeIcon() {
    if (type == NoChannelsType.FAVORITE) {
      return Icons.favorite_border;
    }
    return Icons.replay;
  }

  String _typeMessage() {
    if (type == NoChannelsType.FAVORITE) {
      return "You don't have any favorite channels.";
    }
    return "You don't have any recently viewed channels.";
  }
}
