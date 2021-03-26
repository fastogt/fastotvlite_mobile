import 'package:fastotv_dart/commands_info.dart';
import 'package:fastotvlite/base/streams/live_timeline.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/base/streams/program_time.dart';
import 'package:fastotvlite/base/tv/constants.dart';
import 'package:fastotvlite/base/tv/snackbar.dart';
import 'package:fastotvlite/bloc/live_bloc.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/events/ascending.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/events/tv_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/notification.dart';
import 'package:fastotvlite/player/controller.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/streams/common_widgets.dart';
import 'package:fastotvlite/tv/streams/tv_live_channels.dart';
import 'package:fastotvlite/tv/streams/tv_live_edit_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:player/widgets/player.dart';

class ChannelsTabHomeTV extends StatefulWidget {
  final LiveStreamBlocTV bloc;

  const ChannelsTabHomeTV(this.bloc);

  @override
  _ChannelsTabHomeTVState createState() => _ChannelsTabHomeTVState();
}

class _ChannelsTabHomeTVState extends State<ChannelsTabHomeTV> {
  final FocusNode _categoriesNode = FocusNode();

  bool _isSnackbarActive = false;

  bool notFullScreen = true;

  LivePlayerController _controller;

  String get _currentCategory => widget.bloc.category;

  int currentChannel = 0;

  int currentChannelEPG = 0;

  Map<String, List<LiveStream>> get channelsMap => widget.bloc.streamsMap;

  List<String> get _categories => channelsMap.keys.toList();

  List<LiveStream> get _currentChannels => channelsMap[_currentCategory];

  LiveStream get _currentStream => _currentChannels[currentChannel];

  LiveStream _playing;

  LiveStream _playingEPG;

  final CustomScrollController _channelsController =
      CustomScrollController(itemHeight: TV_LIST_ITEM_SIZE);

  ProgramsBloc programsBloc;

  bool _updateGuideOnScroll = false;

  @override
  void initState() {
    super.initState();
    _playing = _currentStream;
    _playingEPG = _currentStream;
    initPlayerPage(_playing);
    initProgramsBloc(_playingEPG);
    final settings = locator<LocalStorageService>();
    _updateGuideOnScroll = settings.switchGuide();
    final tvTabsEvent = locator<TvTabsEvents>();
    tvTabsEvent.subscribe<OpenedTvSettings>().listen((event) => controlFromTabs(event.value));
    tvTabsEvent.subscribe<TvGuideSwitch>().listen((event) => _onGuideEvent(event.onScroll));
    final tvSearchEvent = locator<SearchEvents>();
    tvSearchEvent
        .subscribe<StreamSearchEvent<LiveStream>>()
        .listen((event) => _onSearch(event.stream));
    _lastViewed();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    programsBloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: widget.bloc.streamsMap,
        stream: widget.bloc.streamsMapUpdates,
        builder: (context, snapshot) => page());
  }

  Widget page() {
    final settings = locator<LocalStorageService>();
    final scale = settings.screenScale();
    final availableSpace = MediaQuery.of(context).size * scale;

    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Visibility(visible: notFullScreen, child: channelsList(availableSpace)),
      Visibility(visible: notFullScreen, child: const VerticalDivider(width: 0.0)),
      Expanded(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[playerArea(availableSpace), channelInfo(availableSpace, scale)])),
      Visibility(visible: notFullScreen, child: programs(availableSpace))
    ]);
  }

  Widget channelsList(Size availableSpace) {
    return ChannelsListTV(
        focus: _categoriesNode,
        onChannels: _onChannel,
        bloc: widget.bloc,
        scrollController: _channelsController,
        size: Size(availableSpace.width * 0.25, availableSpace.height - 56),
        setEpg: () {
          if (_updateGuideOnScroll) {
            currentChannelEPG = 0;
            _setPrograms(currentChannelEPG);
          }
        });
  }

  Widget playerArea(Size availableSpace) {
    return TvPlayerWrap(LitePlayer(controller: _controller), !notFullScreen, _onPlayer);
  }

  Widget channelInfo(Size availableSpace, double scale) {
    return Visibility(
        visible: notFullScreen,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _TimeLine(programsBloc, Size(availableSpace.width * 0.45, 24 * scale)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                    Expanded(
                        child: Text(AppLocalizations.toUtf8(_playing.displayName()),
                            style: TextStyle(fontSize: 18 * scale))),
                    FavoriteStarButton(_playing.favorite(), onFavoriteChanged: (bool value) {
                      widget.bloc.handleFavorite(!_playing.favorite(), _playing);
                    }, unselectedColor: Theming.of(context).onBrightness()),
                    IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
                    IconButton(icon: const Icon(Icons.delete), onPressed: _delete)
                  ]),
                  _ProgramName(programsBloc, 18 * scale),
                  _ProgramDescription(programsBloc, 18 * scale)
                ])));
  }

  Widget programs(Size availableSpace) {
    return Programs(Size(availableSpace.width * 0.3, availableSpace.height - 72), programsBloc);
  }

  void controlFromTabs(bool settingsOpened) {
    if (mounted) {
      if (settingsOpened) {
        _controller.pause();
      } else {
        _controller.playStream(_playing);
      }
    }
  }

  // init
  void initPlayerPage(LiveStream channel) {
    if (_controller != null) {
      return;
    }
    _controller = LivePlayerController(channel);
  }

  void initProgramsBloc(LiveStream channel) {
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          currentChannel = i;
          _playChannel(i);
          _channelsController.moveToPosition(i);
        });

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
    _sendRecent();
    currentChannel = index;
    _playing = _currentChannels[currentChannel];
    initPlayerPage(_playing);
    _controller.playStream(_playing);
    _setPrograms(index);
  }

  void _showSnackBar(bool show) {
    if (show == _isSnackbarActive) {
      return;
    }

    if (show) {
      _isSnackbarActive = true;
      final snack = PlayerSnackbarTV(context, _playing.displayName(), _controller.isPlaying());
      ScaffoldMessenger.of(context).showSnackBar(snack).closed.then((_) {
        _isSnackbarActive = false;
      });
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // epg
  void _onGuideEvent(bool onScroll) {
    _updateGuideOnScroll = onScroll;
    if (!_updateGuideOnScroll) {
      _setPrograms(currentChannel);
    }
  }

  void _setPrograms(int index) {
    currentChannelEPG = index;
    _playingEPG = _currentChannels[index];
    initProgramsBloc(_playingEPG);
    setState(() {});
  }

  // search
  void _onSearch(LiveStream stream) {
    for (int i = 0; i < channelsMap[TR_ALL].length; i++) {
      final s = channelsMap[TR_ALL][i];
      if (s.id() == stream.id()) {
        final result = _categories[_categories.indexOf(TR_ALL)];
        widget.bloc.setCategory(result);
        if (_channelsController.controller.hasClients) {
          _channelsController.moveToPosition(i);
        }
        _playChannel(i);
        break;
      }
    }
  }

  // recent
  void _sendRecent() {
    _controller.sendRecent(_playing);
    if (_currentCategory != TR_RECENT) {
      widget.bloc.addRecent(_playing);
    }
  }

  // remote controls
  bool _onChannel(FocusNode node, RawKeyEvent event, int index) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case BACK:
        case BACKSPACE:
        case KEY_LEFT:
          FocusScope.of(context).requestFocus(_categoriesNode);
          return true;

        case KEY_UP:
          if (_updateGuideOnScroll && currentChannelEPG != 0) {
            currentChannelEPG--;
            _setPrograms(currentChannelEPG);
          }
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          return true;

        case KEY_DOWN:
          if (_updateGuideOnScroll && currentChannelEPG != _currentChannels.length - 1) {
            currentChannelEPG++;
            _setPrograms(currentChannelEPG);
          }
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          return true;

        case ENTER:
        case KEY_CENTER:
          currentChannelEPG = index;
          _playChannel(index);
          return true;

        case KEY_RIGHT:
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
          return true;
      }
      return false;
    });
  }

  bool _onPlayer(FocusNode node, RawKeyEvent event) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case ENTER:
        case KEY_CENTER:
        case PAUSE:
          if (notFullScreen) {
            setFullscreenOff(false);
            _showSnackBar(true);
          } else {
            if (_controller.isPlaying()) {
              _controller.pause();
              _showSnackBar(!_isSnackbarActive);
            } else {
              _controller.play();
              _showSnackBar(!_isSnackbarActive);
            }
          }
          setState(() {});
          return true;

        case BACK:
        case BACKSPACE:
          if (!notFullScreen) {
            setFullscreenOff(true);
            _showSnackBar(false);
            setState(() {});
          }
          return true;

        case KEY_LEFT:
        case PREVIOUS:
          if (!notFullScreen) {
            _showSnackBar(false);
            _playPrev();
          } else {
            FocusScope.of(context).focusInDirection(TraversalDirection.left);
          }
          return true;

        case KEY_RIGHT:
        case NEXT:
          if (!notFullScreen) {
            _showSnackBar(false);
            _playNext();
          } else {
            FocusScope.of(context).focusInDirection(TraversalDirection.right);
          }
          return true;

        case KEY_DOWN:
          if (notFullScreen) {
            FocusScope.of(context).focusInDirection(TraversalDirection.down);
          }
          return true;

        case KEY_UP:
          if (notFullScreen) {
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
          }
          return true;

        case MENU:
          if (!notFullScreen) {
            _showSnackBar(!_isSnackbarActive);
          }
          return true;
      }
      return false;
    });
  }

  void setFullscreenOff(bool visibility) {
    notFullScreen = visibility;
    TvChannelNotification(title: NotificationTypeTV.FULLSCREEN, visibility: notFullScreen)
        .dispatch(context);
    final settings = locator<LocalStorageService>();
    if (notFullScreen) {
      settings.setLastChannel(null);
      widget.bloc.sortRecent();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _channelsController.moveToTop();
      });
    } else {
      _sendRecent();
      settings.setLastChannel(_playing.id());
    }
  }

  // edit
  void _edit() {
    final List<String> oldGroups = [];
    oldGroups.addAll(_currentStream.groups());
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LiveEditPageTV(_currentStream);
    })).then((value) {
      if (value != null) {
        widget.bloc.edit(_currentStream, oldGroups);
        widget.bloc.updateMap();
      }
    });
  }

  void _delete() {
    widget.bloc.delete(_currentStream);
    widget.bloc.updateMap();
    if (widget.bloc.map[TR_ALL].isEmpty) {
      final listEvents = locator<StreamListEvent>();
      listEvents.publish(StreamsListEmptyEvent());
    }
  }
}

class _TimeLine extends StatelessWidget {
  final ProgramsBloc programsBloc;
  final Size size;

  const _TimeLine(this.programsBloc, this.size);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const SizedBox();
          }
          return SizedBox(
              width: size.width,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                LiveTime.current(
                    programmeInfo: snapshot.data, color: Theming.of(context).onBrightness()),
                LiveTimeLine(
                    programmeInfo: snapshot.data,
                    width: size.width / 1.6,
                    height: 6,
                    color: Theme.of(context).accentColor),
                LiveTime.end(
                    programmeInfo: snapshot.data, color: Theming.of(context).onBrightness())
              ]));
        });
  }
}

class _ProgramName extends StatelessWidget {
  final ProgramsBloc programsBloc;
  final double textSize;

  const _ProgramName(this.programsBloc, this.textSize);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return const SizedBox();
          }
          return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(AppLocalizations.toUtf8(snapshot.data?.title ?? ''),
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: textSize)));
        });
  }
}

class _ProgramDescription extends StatelessWidget {
  final ProgramsBloc programsBloc;
  final double textSize;

  const _ProgramDescription(this.programsBloc, this.textSize);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final ProgrammeInfo p = snapshot.data;
            if (p.description != null) {
              return SingleChildScrollView(child: Text(AppLocalizations.toUtf8(p.description)));
            }
          }
          return const SizedBox();
        });
  }
}
