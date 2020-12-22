import 'package:flutter_common/base/controls/favorite_button.dart';
import 'package:flutter_common/base/controls/no_channels.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/scroll_controller_manager.dart';
import 'package:flutter_common/tv/key_code.dart';
import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/base/icon.dart';
import 'package:fastotvlite/base/stream_parser.dart';
import 'package:fastotvlite/base/streams/live_timeline.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/base/streams/program_time.dart';
import 'package:fastotvlite/base/streams/programs_list.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/events/ascending.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/events/tv_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/notification.dart';
import 'package:fastotvlite/player/stream_player.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/streams/tv_live_edit_channel.dart';
import 'package:fastotvlite/tv/tv_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

class ChannelsTabHomeTV extends StatefulWidget {
  final List<LiveStream> channels;

  ChannelsTabHomeTV(this.channels);

  @override
  _ChannelsTabHomeTVState createState() {
    return _ChannelsTabHomeTVState();
  }
}

class _ChannelsTabHomeTVState extends State<ChannelsTabHomeTV> {
  static const LIST_ITEM_SIZE = 64.0;
  static const LIST_HEADER_SIZE = 32.0;

  FocusNode _categoriesNode = FocusNode();

  bool _isSnackbarActive = false;

  bool notFullScreen = true;

  double scale;

  StreamPlayerPage _playerPage;

  FocusNode playerFocus = FocusNode();

  String _currentCategory = TR_ALL;

  int currentChannel = 0;

  Map<String, List<LiveStream>> channelsMap = {};

  List<String> get _categories => channelsMap.keys.toList();

  List<LiveStream> get _currentChannels => channelsMap[_currentCategory];

  LiveStream get _currentStream => _currentChannels[currentChannel];

  LiveStream _playing;

  CustomScrollController _channelsController = CustomScrollController(itemHeight: LIST_ITEM_SIZE);

  ProgramsBloc programsBloc;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    scale = settings.screenScale();
    _parseChannels();

    final tvTabsEvent = locator<TvTabsEvents>();
    tvTabsEvent.subscribe<OpenedTvSettings>().listen((event) => controlFromTabs(event.value));

    final _search = locator<SearchEvents>();
    _search.subscribe<SearchEvent<LiveStream>>().listen((event) {
      _onSearch(event.stream);
    });

    _playing = _currentChannels[0];
    _initPlayerPage(_playing);
    _initProgramsBloc(_playing);
    WidgetsBinding.instance.addPostFrameCallback((_) => _lastViewed());
  }

  @override
  void dispose() {
    super.dispose();
    programsBloc.dispose();
    _channelsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableSpace = MediaQuery.of(context).size * scale;

    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Visibility(
          visible: notFullScreen,
          child: Column(
              children: <Widget>[categoriesList(availableSpace), Divider(height: 0.0), channelsList(availableSpace)])),
      Visibility(visible: notFullScreen, child: VerticalDivider(width: 0.0)),
      Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        _TvPlayerWrap(_playerPage, availableSpace, !notFullScreen, _onPlayer),
        Visibility(visible: notFullScreen, child: channelInfo(availableSpace))
      ])),
      Visibility(visible: notFullScreen, child: programs(availableSpace))
    ]);
  }

  Widget categoriesList(Size availableSpace) {
    return _Categories(
        focus: _categoriesNode,
        onKey: (event, node) => _onCategory(event, node),
        category: _currentCategory,
        size: Size(availableSpace.width / 5, LIST_HEADER_SIZE));
  }

  Widget channelsList(Size availableSpace) {
    final _size = Size(availableSpace.width / 5, availableSpace.height - LIST_HEADER_SIZE - 72);
    if (_currentCategory == TR_FAVORITE && channelsMap[TR_FAVORITE].isEmpty) {
      return _NoChannels.favorite(_size);
    } else if (_currentCategory == TR_RECENT && channelsMap[TR_RECENT].isEmpty) {
      return _NoChannels.recent(_size);
    }
    return _ChannelsList(
        onKey: (node, event, index) => _onChannel(node, event, index),
        channels: _currentChannels,
        scrollController: _channelsController.controller,
        itemHeight: LIST_ITEM_SIZE,
        size: _size);
  }

  Widget channelInfo(Size availableSpace) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
          _TimeLine(programsBloc, Size(availableSpace.width / 2, 36 * scale)),
          SizedBox(height: 16 * scale),
          Row(children: <Widget>[
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(AppLocalizations.of(context).translate(TR_CURRENT_CHANNEL)),
              Text(AppLocalizations.toUtf8(_playing.displayName()),
                  style: TextStyle(fontSize: 24 * scale), overflow: TextOverflow.ellipsis)
            ]),
            Spacer(),
            FavoriteStarButton(_playing.favorite(), onFavoriteChanged: (bool value) => _handleFavorite()),
            CustomIcons(Icons.edit, () => _editChannel(_playing)),
            CustomIcons(Icons.delete, () => _deleteChannel(_playing))
          ]),
          SizedBox(height: 16 * scale),
          _ProgramTitle(programsBloc),
          _ProgramName(programsBloc, Size(availableSpace.width / 2, 24 * scale), 24 * scale)
        ]));
  }

  Widget programs(Size availableSpace) {
    return _Programs(
        LIST_ITEM_SIZE, Size(availableSpace.width * 0.3, availableSpace.height - TABBAR_HEIGHT), programsBloc);
  }

  Color selectedColor(FocusNode focus) => focus.hasPrimaryFocus ? Theme.of(context).accentColor : Colors.grey;

  void controlFromTabs(bool settingsOpened) {
    if (mounted) {
      if (settingsOpened) {
        _playerPage.pause();
      } else {
        _playerPage.playChannel(_playing);
      }
    }
  }

  // init
  void _parseChannels() {
    channelsMap = StreamsParser<LiveStream>(widget.channels).parseChannels();
  }

  void _initPlayerPage(LiveStream channel) {
    if (_playerPage != null) {
      return;
    }
    _playerPage = StreamPlayerPage(channel: channel);
  }

  void _initProgramsBloc(LiveStream channel) {
    programsBloc = ProgramsBloc(channel);
  }

  void _lastViewed() {
    final settings = locator<LocalStorageService>();

    final lastChannelID = settings.lastChannel();
    if (lastChannelID == null) {
      return;
    }

    final channels = channelsMap[TR_ALL];
    for (int i = 0; i < channels.length; i++) {
      if (channels[i].id() == lastChannelID) {
        currentChannel = i;
        _playChannel(i);
        _channelsController.moveToPosition(i);
        setFullscreenOff(false);
        return;
      }
    }
  }

  // player
  void _playNext() {
    if (currentChannel == _currentChannels.length - 1) {
      if (notFullScreen) {
        _channelsController.moveToTop();
      }
      currentChannel = 0;
    } else {
      if (notFullScreen) {
        _channelsController.moveDown();
      }
      currentChannel++;
    }
    _playing = _currentStream;
    _playChannel(currentChannel);
  }

  void _playPrev() {
    if (currentChannel == 0) {
      if (notFullScreen) {
        _channelsController.moveToBottom();
      }
      currentChannel = _currentChannels.length - 1;
    } else {
      if (notFullScreen) {
        _channelsController.moveUp();
      }
      currentChannel--;
    }
    _playing = _currentStream;
    _playChannel(currentChannel);
  }

  void _playChannel(int index) {
    currentChannel = index;
    _playing = _currentChannels[currentChannel];
    _initProgramsBloc(_playing);
    _playerPage.playChannel(_playing);
  }

  void _showSnackBar(bool show) {
    if (show == _isSnackbarActive) {
      return;
    }

    if (show) {
      _isSnackbarActive = true;
      final contentColor = Theming.of(context).onBrightness();
      final backColor = Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white70;
      final snack = SnackBar(
          backgroundColor: backColor,
          content: Container(
              child: Row(children: <Widget>[
            SizedBox(width: 32),
            Text(AppLocalizations.toUtf8(_playing.displayName()),
                style: TextStyle(fontSize: 36, color: contentColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false),
            Spacer(),
            Icon(_playerPage.isPlaying() ? Icons.pause : Icons.play_arrow, size: 48, color: contentColor)
          ])));
      Scaffold.of(context).showSnackBar(snack).closed.then((_) {
        _isSnackbarActive = false;
      });
    } else {
      Scaffold.of(context).hideCurrentSnackBar();
    }
  }

  // search
  void _onSearch(LiveStream stream) {
    for (int i = 0; i < channelsMap[TR_ALL].length; i++) {
      final s = channelsMap[TR_ALL][i];
      if (s.displayName() == stream.displayName()) {
        _currentCategory = _categories[_categories.indexOf(TR_ALL)];
        if (_channelsController.controller.hasClients) {
          _channelsController.moveToPosition(i);
        }
        setState(() {});
        _playChannel(i);
        break;
      }
    }
  }

  // favorite
  void _addFavorite(LiveStream channel) {
    channelsMap[TR_FAVORITE].insert(0, channel);
  }

  void _deleteFavorite(LiveStream channel) {
    channelsMap[TR_FAVORITE].remove(channel);
  }

  void _handleFavorite() {
    _playing.setFavorite(!_playing.favorite());
    !_playing.favorite() ? _deleteFavorite(_playing) : _addFavorite(_playing);
    setState(() {});
  }

  // recent
  void sendRecent() {
    DateTime now = DateTime.now();
    _playing.setRecentTime(now.millisecondsSinceEpoch);
    _addRecent(_playing);
  }

  void _addRecent(LiveStream channel) {
    if (channelsMap[TR_RECENT].contains(channel)) {
      channelsMap[TR_RECENT].sort((b, a) => a.recentTime().compareTo(b.recentTime()));
    } else {
      channelsMap[TR_RECENT].insert(0, channel);
    }
    setState(() {});
  }

  void _deleteChannel(LiveStream channel) {
    final categories = channel.groups();
    widget.channels.remove(channel);
    if (widget.channels.isNotEmpty) {
      channelsMap[TR_ALL].remove(channel);
      if (channelsMap[TR_RECENT].contains(channel)) {
        channelsMap[TR_RECENT].remove(channel);
      }
      if (channelsMap[TR_FAVORITE].contains(channel)) {
        channelsMap[TR_FAVORITE].remove(channel);
      }
      for (String category in categories) {
        if (channelsMap.containsKey(category)) {
          channelsMap[category].remove(channel);
          if (channelsMap[category].isEmpty) {
            channelsMap.remove(category);
            _categories.remove(category);
            _currentCategory = TR_ALL;
          }
        }
      }
      _playChannel(0);
    } else {
      channelsMap.clear();
      final listEvents = locator<StreamListEvent>();
      listEvents.publish(StreamsListEmptyEvent());
    }
    setState(() {});
  }

  void _editChannel(LiveStream channel) async {
    final epgUrl = channel.epgUrl();
    LiveStream response =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => LiveEditPageTV(channel)));
    _parseChannels();
    if (response.epgUrl() != epgUrl) {
      channel.setRequested(false);
      programsBloc = ProgramsBloc(channel);
    }
    if (mounted) {
      setState(() {});
    }
  }

  // controls
  bool _onCategory(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      if (node.hasFocus || node.hasPrimaryFocus) {
        RawKeyDownEvent rawKeyDownEvent = event;
        RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
        switch (rawKeyEventDataAndroid.keyCode) {
          case BACK:
          case BACKSPACE:
          case KEY_UP:
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
            break;

          case ENTER:
          case KEY_CENTER:
          case KEY_DOWN:
            FocusScope.of(context).focusInDirection(TraversalDirection.down);
            break;

          case KEY_RIGHT:
            int _cur = _categories.indexOf(_currentCategory);
            if (_cur == _categories.length - 1) {
              _cur = 0;
            } else {
              _cur++;
            }
            _currentCategory = _categories[_cur];
            if (_channelsController.controller.hasClients) {
              _channelsController.moveToTop();
            }
            break;

          case KEY_LEFT:
            int _cur = _categories.indexOf(_currentCategory);
            if (_cur == 0) {
              _cur = _categories.length - 1;
            } else {
              _cur--;
            }
            _currentCategory = _categories[_cur];
            if (_channelsController.controller.hasClients) {
              _channelsController.moveToTop();
            }
            break;

          default:
            break;
        }
        setState(() {});
      }
    }
    return node.hasFocus;
  }

  bool _onChannel(FocusNode node, RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      if (node.hasFocus || node.hasPrimaryFocus) {
        RawKeyDownEvent rawKeyDownEvent = event;
        RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
        switch (rawKeyEventDataAndroid.keyCode) {
          case BACK:
          case BACKSPACE:
          case KEY_LEFT:
            FocusScope.of(context).requestFocus(_categoriesNode);
            break;

          case KEY_UP:
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
            break;

          case KEY_DOWN:
            FocusScope.of(context).focusInDirection(TraversalDirection.down);
            break;

          case ENTER:
          case KEY_CENTER:
            _playChannel(index);
            break;

          case KEY_RIGHT:
            FocusScope.of(context).focusInDirection(TraversalDirection.right);
            break;

          default:
            break;
        }
        setState(() {});
      }
    }
    return node.hasFocus;
  }

  bool _onPlayer(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      if (node.hasFocus || node.hasPrimaryFocus) {
        RawKeyDownEvent rawKeyDownEvent = event;
        RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
        switch (rawKeyEventDataAndroid.keyCode) {

          /// Opens fullscreen player
          case ENTER:
          case KEY_CENTER:
          case PAUSE:
            if (notFullScreen) {
              setFullscreenOff(false);
              _showSnackBar(true);
            } else {
              if (_playerPage.isPlaying()) {
                _playerPage.pause();
                _showSnackBar(!_isSnackbarActive);
              } else {
                _playerPage.play();
                _showSnackBar(!_isSnackbarActive);
              }
            }
            break;

          case BACK:
          case BACKSPACE:
            if (!notFullScreen) {
              setFullscreenOff(true);
              _showSnackBar(false);
            }
            break;

          case KEY_LEFT:
          case PREVIOUS:
            if (!notFullScreen) {
              sendRecent();
              _playPrev();
            } else {
              FocusScope.of(context).focusInDirection(TraversalDirection.left);
            }
            break;

          case KEY_RIGHT:
          case NEXT:
            if (!notFullScreen) {
              sendRecent();
              _playNext();
            } else {
              FocusScope.of(context).focusInDirection(TraversalDirection.right);
            }
            break;

          case MENU:
            if (!notFullScreen) {
              _showSnackBar(!_isSnackbarActive);
            }
            break;

          case KEY_DOWN:
            FocusScope.of(context).focusInDirection(TraversalDirection.down);
            break;

          case KEY_UP:
            if (notFullScreen) {
              FocusScope.of(context).focusInDirection(TraversalDirection.up);
            }
            break;

          default:
            break;
        }
        setState(() {});
      }
    }
    return node.hasFocus;
  }

  void setFullscreenOff(bool visibility) {
    notFullScreen = visibility;
    TvChannelNotification(title: NotificationType.FULLSCREEN, visibility: notFullScreen)..dispatch(context);
    final settings = locator<LocalStorageService>();
    if (notFullScreen) {
      settings.setLastChannel(null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _channelsController.jumpToPosition(currentChannel);
      });
    } else {
      sendRecent();
      settings.setLastChannel(_playing.id());
    }
  }
}

class _Categories extends StatefulWidget {
  final String category;
  final Size size;
  final FocusNode focus;
  final bool Function(FocusNode node, RawKeyEvent event) onKey;

  _Categories({this.category, this.size, this.onKey, this.focus});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<_Categories> {
  Color _color;

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
    return Focus(
        focusNode: widget.focus,
        onKey: (event, node) => widget.onKey(event, node),
        child: Container(
            width: widget.size.width,
            height: widget.size.height,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Icon(Icons.keyboard_arrow_left, color: _color ?? Theme.of(context).disabledColor),
              Text(_title(widget.category)),
              Icon(Icons.keyboard_arrow_right, color: _color ?? Theme.of(context).disabledColor)
            ])));
  }

  void _onFocusChange() {
    setState(() {
      if (widget.focus.hasFocus) {
        _color = Theme.of(context).accentColor;
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
}

class _ChannelsList extends StatelessWidget {
  final List<LiveStream> channels;
  final ScrollController scrollController;
  final Size size;
  final double itemHeight;
  final bool Function(FocusNode node, RawKeyEvent event, int index) onKey;

  _ChannelsList(
      {@required this.channels, this.scrollController, @required this.onKey, this.itemHeight, @required this.size});

  @override
  Widget build(BuildContext context) {
    final _itemHeight = itemHeight ?? 64;
    return Container(
        width: size.width,
        height: size.height,
        child: ListView.builder(
            controller: scrollController ?? ScrollController(),
            itemCount: channels.length,
            itemExtent: _itemHeight,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return _ChannelTile(
                  channel: channel, onKey: (node, event) => onKey(node, event, index), itemHeight: _itemHeight);
            }));
  }
}

class _ChannelTile extends StatefulWidget {
  final LiveStream channel;
  final double itemHeight;
  final bool Function(FocusNode node, RawKeyEvent event) onKey;

  _ChannelTile({@required this.channel, @required this.onKey, this.itemHeight});

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
        onKey: (node, event) => widget.onKey(node, event),
        child: Stack(children: <Widget>[_background(), _tile()]));
  }

  // private:
  Widget _background() {
    return Container(
      color: _backgroundColor(),
    );
  }

  Widget _tile() {
    return ListTile(
        leading: _channelAvatar(widget.channel),
        title: Text(AppLocalizations.toUtf8(widget.channel.displayName()),
            style: TextStyle(fontSize: widget.itemHeight / 4), maxLines: 2, overflow: TextOverflow.ellipsis));
  }

  Widget _channelAvatar(LiveStream channel) {
    return PreviewIcon.live(channel.icon(), height: CHANNEL_AVATAR_SIZE.height, width: CHANNEL_AVATAR_SIZE.width);
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

class _TimeLine extends StatelessWidget {
  final ProgramsBloc programsBloc;
  final Size size;

  _TimeLine(this.programsBloc, this.size);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return SizedBox();
          }
          return Container(
              width: size.width,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                LiveTime.current(programmeInfo: snapshot.data),
                LiveTimeLine(
                    programmeInfo: snapshot.data,
                    width: size.width / 1.5,
                    height: 6,
                    color: Theme.of(context).accentColor),
                LiveTime.end(programmeInfo: snapshot.data)
              ]));
        });
  }
}

class _ProgramName extends StatelessWidget {
  final ProgramsBloc programsBloc;
  final Size size;
  final double textSize;

  _ProgramName(this.programsBloc, this.size, this.textSize);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return SizedBox();
          }
          return Container(
              height: size.height,
              width: size.width,
              child: Text(AppLocalizations.toUtf8(snapshot.data?.title ?? ''),
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: textSize)));
        });
  }
}

class _ProgramTitle extends StatelessWidget {
  final ProgramsBloc programsBloc;

  _ProgramTitle(this.programsBloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return SizedBox();
          }
          return Text(AppLocalizations.of(context).translate(TR_NOW_PLAYING));
        });
  }
}

class _Programs extends StatelessWidget {
  final ProgramsBloc programsBloc;
  final Size size;
  final double itemHeight;

  _Programs(this.itemHeight, this.size, this.programsBloc);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size.width,
        height: size.height,
        child: ProgramsListView(
            itemHeight: itemHeight, programsBloc: programsBloc, textColor: Theming.of(context).onBrightness()));
  }
}

class _TvPlayerWrap extends StatefulWidget {
  final Widget child;
  final Size availableSpace;
  final bool fullscreen;
  final bool Function(FocusNode node, RawKeyEvent event) onKey;

  _TvPlayerWrap(this.child, this.availableSpace, this.fullscreen, this.onKey);

  @override
  _TvPlayerWrapState createState() => _TvPlayerWrapState();
}

class _TvPlayerWrapState extends State<_TvPlayerWrap> {
  FocusNode _node = FocusNode();
  Color _color = Colors.transparent;

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
  void didUpdateWidget(_TvPlayerWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: !widget.fullscreen ? widget.availableSpace.height / 2 : widget.availableSpace.height,
        decoration: BoxDecoration(color: Colors.black, border: Border.all(color: _color, width: 2)),
        child: Focus(onKey: widget.onKey, focusNode: _node, child: widget.child, autofocus: widget.fullscreen));
  }

  void _onFocusChange() {
    _setColor();
  }

  void _setColor() {
    setState(() {
      if (widget.fullscreen || !_node.hasFocus) {
        _color = Colors.transparent;
      } else {
        _color = Theme.of(context).accentColor;
      }
    });
  }
}

class _NoChannels extends StatelessWidget {
  final int type;
  final Size size;

  _NoChannels.favorite(this.size) : type = 0;

  _NoChannels.recent(this.size) : type = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size.height,
        width: size.width,
        child: Center(
            child: NonAvailableBuffer(
                iconSize: 48,
                icon: type == 0 ? Icons.favorite_border : Icons.replay,
                message: AppLocalizations.of(context).translate(_type()))));
  }

  String _type() {
    if (type == 0) {
      return TR_FAVORITE_LIVE;
    } else {
      return TR_RECENT_LIVE;
    }
  }
}
