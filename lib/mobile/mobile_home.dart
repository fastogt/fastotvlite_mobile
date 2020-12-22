import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter_common/base/controls/logo.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:fastotvlite/base/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/constants.dart';
import 'package:fastotvlite/events/ascending.dart';
import 'package:fastotvlite/events/descending.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/mobile/settings/settings_page.dart';
import 'package:fastotvlite/mobile/streams/live_search.dart';
import 'package:fastotvlite/mobile/streams/live_tab.dart';
import 'package:fastotvlite/mobile/vods/vod_search.dart';
import 'package:fastotvlite/mobile/vods/vod_tab.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';
import 'package:unicorndial/unicorndial.dart';

class HomePage extends StatefulWidget {
  final List<LiveStream> channels;
  final List<VodStream> vods;

  HomePage(this.channels, this.vods);

  @override
  VideoAppState createState() => VideoAppState();
}

class VideoAppState<C extends IStream> extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  VideoAppState();

  GlobalKey _liveKey = GlobalKey();
  GlobalKey _vodKey = GlobalKey();

  List<LiveStream> _channels = [];
  List<VodStream> _vods = [];

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  List<String> _videoTypesList = [];
  String _selectedType;

  String _translate(String key) => AppLocalizations.of(context).translate(key);

  void _fillTypes() {
    /// if current video type list contains
    /// last saved type, sets it do current type
    final settings = locator<LocalStorageService>();
    bool isSaved = settings.saveLastViewed();
    String lastType;
    String lastChannel = settings.lastChannel();

    if (_channels.isEmpty && widget.vods.isEmpty) {
      _selectedType = TR_EMPTY;
      return;
    }

    // Find all stream types
    if (_channels.isNotEmpty) {
      final title = TR_LIVE_TV;
      _videoTypesList.add(title);
      if (isSaved) {
        for (int i = 0; i < _channels.length; i++) {
          if (_channels[i].id() == lastChannel) {
            lastType = title;
          }
        }
      }
    }
    if (widget.vods.isNotEmpty) {
      final title = TR_VODS;
      _videoTypesList.add(title);
      if (isSaved && lastType == null) {
        for (int i = 0; i < widget.vods.length; i++) {
          if (widget.vods[i].id() == lastChannel) {
            lastType = title;
          }
        }
      }
    }

    if (lastType != null && isSaved) {
      _selectedType = _videoTypesList.contains(lastType) ? lastType : _videoTypesList[0];
    } else {
      _selectedType = _videoTypesList[0];
    }
  }

  Widget _getCurrentTabWidget() {
    switch (_selectedType) {
      case TR_LIVE_TV:
        return LiveTab(_liveKey, _channels);
      case TR_VODS:
        return VodTab(_vodKey, _vods);

      default:
        return Center(
            child: Padding(padding: EdgeInsets.all(24), child: Text(_translate(TR_NO_STREAMS), softWrap: true)));
    }
  }

  IconData _iconFromType(String type) {
    if (type == TR_LIVE_TV) {
      return Icons.personal_video;
    } else if (type == TR_VODS) {
      return Icons.ondemand_video;
    }
    return Icons.warning;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final events = locator<StreamListEvent>();
    events.subscribe<StreamsListEmptyEvent>().listen((_) => _onTypeDelete());
    ChromeCastInfo(); // init
    _channels = widget.channels;
    _vods = widget.vods;
    _fillTypes();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveStreams();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _saveStreams();
  }

  @override
  Widget build(BuildContext context) {
    final onPrimaryColor = Theming.of(context).onCustomColor(Theme.of(context).primaryColor);
    return WillPopScope(
        onWillPop: () async => false,
        child: Builder(builder: (context) {
          return Scaffold(
              key: _drawerKey,
              appBar: _appBar(onPrimaryColor),
              drawer: _drawer(),
              body: DoubleBackToCloseApp(
                  snackBar: const SnackBar(content: Text('Tap back again to exit')), child: _getCurrentTabWidget()),
              floatingActionButton: _floatingButton());
        }));
  }

  Widget _appBar(Color iconColor) {
    double _elevation() {
      if (_selectedType == TR_EMPTY) {
        return 4;
      }
      return 0;
    }

    return AppBar(
        elevation: _elevation(),
        automaticallyImplyLeading: false,
        title: Text(_translate(_selectedType), style: TextStyle(color: iconColor)),
        leading:
            IconButton(icon: Icon(Icons.menu, color: iconColor), onPressed: () => _drawerKey.currentState.openDrawer()),
        actions: <Widget>[_search(iconColor)]);
  }

  Widget _search(Color iconsColor) {
    if (_selectedType == TR_CATCHUPS) {
      return SizedBox();
    }

    return IconButton(icon: Icon(Icons.search, color: iconsColor), onPressed: () => _onSearch());
  }

  Widget _drawer() {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(child: Center(child: Logo(LOGO_PATH))),
      _streamTypeTiles(),
      _settingsTile()
    ]));
  }

  Widget _streamTypeTiles() {
    final iconColor = Theming.of(context).onBrightness();
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: List<ListTile>.generate(_videoTypesList.length, (int index) {
          final type = _videoTypesList[index];
          final title = _translate(type);
          final icon = _iconFromType(type);
          return ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(title),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedType = _videoTypesList[index];
                });
              });
        }));
  }

  Widget _settingsTile() {
    return ListTile(
        leading: Icon(Icons.settings, color: Theming.of(context).onBrightness()),
        title: Text(_translate(TR_SETTINGS)),
        onTap: () async {
          Navigator.pop(context);
          final settings = locator<LocalStorageService>();
          final oldEpgLink = settings.epgLink();
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));
          final epgLink = settings.epgLink();
          if (oldEpgLink != epgLink) {
            _channels.forEach((channel) {
              channel.setRequested(false);
              channel.setEpgUrl(epgLink);
            });
            final settings = locator<LocalStorageService>();
            settings.saveLiveChannels(_channels);
          }
        });
  }

  Widget _floatingButton() {
    final _theme = Theme.of(context);
    return UnicornDialer(
        backgroundColor: _theme.primaryColor.withOpacity(0.4),
        parentButtonBackground: _theme.accentColor,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: [
          UnicornButton(
              labelColor: Theming.of(context).onBrightness(),
              labelBackgroundColor: Colors.transparent,
              labelText: _translate(TR_SINGLE_STREAM),
              labelHasShadow: false,
              hasLabel: true,
              currentButton: FloatingActionButton(
                  heroTag: "single",
                  backgroundColor: _theme.accentColor,
                  mini: true,
                  onPressed: () => _addStreams(PickStreamFrom.SINGLE_STREAM),
                  child: Icon(Icons.add_to_queue))),
          UnicornButton(
              labelColor: Theming.of(context).onBrightness(),
              labelBackgroundColor: Colors.transparent,
              labelText: _translate(TR_PLAYLIST),
              labelHasShadow: false,
              hasLabel: true,
              currentButton: FloatingActionButton(
                  heroTag: "playlist",
                  backgroundColor: _theme.accentColor,
                  mini: true,
                  onPressed: () => _addStreams(PickStreamFrom.PLAYLIST),
                  child: Icon(Icons.playlist_add))),
        ]);
  }

  // search
  SearchDelegate _searchDelegate() {
    switch (_selectedType) {
      case TR_LIVE_TV:
        return LiveStreamSearch(widget.channels, _translate(TR_SEARCH_LIVE));
      case TR_VODS:
        return VodStreamSearch(widget.vods, _translate(TR_SEARCH_VOD));
      default:
        return null;
    }
  }

  void _onSearch() async {
    final result = await showSearch(context: context, delegate: _searchDelegate());
    if (result != null) {
      _sendSearchEvent(result);
    }
  }

  void _sendSearchEvent(stream) {
    final _searchEvents = locator<SearchEvents>();
    switch (_selectedType) {
      case TR_LIVE_TV:
        _searchEvents.publish(SearchEvent<LiveStream>(stream));
        break;
      case TR_VODS:
        _searchEvents.publish(SearchEvent<VodStream>(stream));
        break;
      default:
    }
  }

  // add/edit streams
  void _onTypeDelete() {
    if (_channels.isEmpty && widget.vods.isEmpty) {
      _selectedType = TR_EMPTY;
      _videoTypesList.clear();
    } else {
      _videoTypesList.remove(_selectedType);
      _selectedType = _videoTypesList.first;
    }
  }

  void _addStreams(PickStreamFrom source) async {
    AddStreamResponse response =
        await showDialog(context: context, builder: (BuildContext context) => FilePickerDialog(source));
    if (response == null) {
      _drawerKey.currentState.showSnackBar(SnackBar(
          content: Text(_translate(TR_NO_CHANNELS_ADDED)),
          action: SnackBarAction(
              label: _translate(TR_CLOSE), onPressed: () => _drawerKey.currentState.hideCurrentSnackBar())));
    } else {
      if (response.type == StreamType.Live) {
        _addLiveStreams(response.channels);
      } else {
        _addVodStreams(response.vods);
      }
      setState(() {});
    }
  }

  void _addLiveStreams(List<LiveStream> streams) {
    if (!_videoTypesList.contains(TR_LIVE_TV)) {
      _videoTypesList.add(TR_LIVE_TV);
    }
    _selectedType = TR_LIVE_TV;

    streams.forEach((channel) {
      bool contains = _contains(_channels, channel);
      if (!contains) {
        _channels.add(channel);
      }
    });

    final events = locator<StreamListEvent>();
    events.publish(StreamsAddedEvent());
    _saveStreams(type: StreamType.Live);
  }

  void _addVodStreams(List<VodStream> streams) {
    if (!_videoTypesList.contains(TR_VODS)) {
      _videoTypesList.add(TR_VODS);
    }
    _selectedType = TR_VODS;

    streams.forEach((stream) {
      bool contains = _contains(_vods, stream);
      if (!contains) {
        _vods.add(stream);
      }
    });

    final events = locator<StreamListEvent>();
    events.publish(StreamsAddedEvent());
    _saveStreams(type: StreamType.Vod);
  }

  void _saveStreams({StreamType type}) {
    final settings = locator<LocalStorageService>();
    if (type == null) {
      settings.saveLiveChannels(_channels);
      settings.saveVods(_vods);
    } else {
      if (type == StreamType.Live) {
        settings.saveLiveChannels(_channels);
      }
      if (type == StreamType.Vod) {
        settings.saveVods(_vods);
      }
    }
  }

  bool _contains<U extends IStream>(List<U> list, U add) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].primaryUrl() == add?.primaryUrl()) {
        return true;
      }
    }
    return false;
  }
}
