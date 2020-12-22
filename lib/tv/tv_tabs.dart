import 'package:fastotvlite/base/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/base/icon.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/constants.dart';
import 'package:fastotvlite/events/ascending.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/events/tv_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/notification.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/add_streams/tv_add_stream_dialog.dart';
import 'package:fastotvlite/tv/add_streams/tv_stream_quantity.dart';
import 'package:fastotvlite/tv/exit_dialog.dart';
import 'package:fastotvlite/tv/search_page.dart';
import 'package:fastotvlite/tv/settings/tv_settings_page.dart';
import 'package:fastotvlite/tv/streams/tv_live_tab_alt.dart';
import 'package:fastotvlite/tv/vods/tv_vod_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/logo.dart';
import 'package:flutter_common/clock.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/screen_orientation.dart' as orientation;

class HomeTV extends StatefulWidget {
  final List<LiveStream> channels;
  final List<VodStream> vods;

  HomeTV(this.channels, this.vods);

  @override
  _HomeTVState createState() => _HomeTVState();
}

const TABBAR_HEIGHT = 72;

class _HomeTVState extends State<HomeTV> with TickerProviderStateMixin, WidgetsBindingObserver {
  final List<String> _tabNodes = [];
  List<Widget> _typesTabView = [];

  List<LiveStream> _channels = [];
  List<VodStream> _vods = [];

  TabController _tabController;
  int _currentType = 0;
  bool isVisible = true;

  Widget _homeWidget;

  double _scale;

  String selectedType;

  void _initTypes() {
    if (widget.channels.isEmpty && widget.vods.isEmpty) {
      selectedType = TR_EMPTY;
      return;
    }

    final settings = locator<LocalStorageService>();
    bool isSaved = settings.saveLastViewed();
    String lastChannel = settings.lastChannel();
    int lastType;

    if (_channels.isNotEmpty) {
      final live = TR_LIVE_TV;
      _tabNodes.add(live);

      _typesTabView.add(ChannelsTabHomeTV(_channels));

      if (isSaved) {
        for (int i = 0; i < _channels.length; i++) {
          if (_channels[i].id() == lastChannel) {
            lastType = 0;
          }
        }
      }
    }
    if (_vods.isNotEmpty) {
      final vods = TR_VODS;
      _tabNodes.add(vods);
      _typesTabView.add(TVVodPage(_vods));
      if (isSaved && lastType == null) {
        for (int i = 0; i < _vods.length; i++) {
          if (_vods[i].id() == lastChannel) {
            lastType = 1;
          }
        }
      }
    }
    _initTabController();
  }

  void _initTabController() {
    _tabController = TabController(vsync: this, length: _tabNodes.length, initialIndex: _currentType);
  }

  @override
  void initState() {
    orientation.onlyLandscape();
    super.initState();

    final events = locator<StreamListEvent>();
    events.subscribe<StreamsListEmptyEvent>().listen((_) => _onTypeDelete());

    final settings = locator<LocalStorageService>();
    _scale = settings.screenScale();

    _channels = widget.channels;
    _vods = widget.vods;
    _initTypes();

    _homeWidget = _home();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveStreams();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool onTitlePush(TvChannelNotification notification) {
    switch (notification.title) {
      case NotificationType.FULLSCREEN:
        if (isVisible != notification.visibility) {
          setState(() {
            isVisible = notification.visibility;
          });
        }
        break;
      default:
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: NotificationListener<TvChannelNotification>(
            onNotification: onTitlePush,
            child: FractionallySizedBox(
                widthFactor: _scale,
                heightFactor: _scale,
                child: new Scaffold(
                    resizeToAvoidBottomPadding: false,
                    backgroundColor: Theme.of(context).primaryColor,
                    body: Column(children: <Widget>[
                      Visibility(
                          visible: isVisible,
                          child: AppBar(
                              leading: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 0, 8), child: Logo(LOGO_PATH)),
                              backgroundColor: Colors.transparent,
                              iconTheme: IconThemeData(color: Theming.of(context).onBrightness()),
                              actionsIconTheme: IconThemeData(color: Theming.of(context).onBrightness()),
                              elevation: 0,
                              title: Row(children: <Widget>[
                                SizedBox(width: 16),
                                TabBar(
                                    indicatorColor: Theme.of(context).accentColor,
                                    controller: _tabController,
                                    isScrollable: true,
                                    tabs: List<_Tab>.generate(_tabNodes.length, (int index) => _Tab(_tabNodes[index])))
                              ]),
                              actions: <Widget>[
                                selectedType == TR_EMPTY ? SizedBox() : CustomIcons(Icons.search, () => _onSearch()),
                                CustomIcons(Icons.add_circle, () => _onAdd()),
                                CustomIcons(Icons.settings, () => _toSettings()),
                                CustomIcons(Icons.power_settings_new, () => _showExitDialog()),
                                _clock()
                              ])),
                      Expanded(child: _homeWidget)
                    ])))));
  }

  Widget _home() {
    return _tabNodes.length > 0
        ? TabBarView(key: UniqueKey(), controller: _tabController, children: _typesTabView)
        : Center(child: Text(TR_NO_STREAMS, style: TextStyle(fontSize: 24)));
  }

  Widget _clock() {
    final settings = locator<LocalStorageService>();
    final _initFormat = settings.timeFormat();
    final tvTabsEvents = locator<TvTabsEvents>();
    final color = Theming.of(context).onBrightness();
    return StreamBuilder<ClockFormatChanged>(
        initialData: ClockFormatChanged(_initFormat),
        stream: tvTabsEvents.subscribe<ClockFormatChanged>(),
        builder: (context, snapshot) => Clock.full(width: 108, textColor: color, hour24: snapshot.data.hour24));
  }

  void _onSearch() {
    switch (selectedType) {
      case TR_LIVE_TV:
        _openSearchPage<LiveStream>(_channels);
        break;
      case TR_VODS:
        _openSearchPage<VodStream>(_vods);
        break;
      default:
        break;
    }
  }

  void _openSearchPage<T extends IStream>(List<T> streams) async {
    final tvTabsEvents = locator<TvTabsEvents>();
    tvTabsEvents.publish(OpenedTvSettings(true));
    T stream = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(streams)));
    tvTabsEvents.publish(OpenedTvSettings(false));
    if (stream != null) {
      final _search = locator<SearchEvents>();
      _search.publish(SearchEvent<T>(stream));
    }
  }

  void _toSettings() async {
    final tvTabsEvents = locator<TvTabsEvents>();
    tvTabsEvents.publish(OpenedTvSettings(true));
    double padding = await Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPageTV()));
    tvTabsEvents.publish(OpenedTvSettings(false));
    setState(() => _scale = padding);
  }

  void _onAdd() async {
    PickStreamFrom _source =
        await showDialog(context: context, builder: (BuildContext context) => StreamTypePickerTV());
    if (_source != null) {
      AddStreamResponse result =
          await showDialog(context: context, builder: (BuildContext context) => FilePickerDialogTV(_source));
      if (result != null) {
        if (result.type == StreamType.Live) {
          _addLiveStreams(result.channels);
          _saveStreams(type: StreamType.Live);
        } else {
          _addVodStreams(result.vods);
          _saveStreams(type: StreamType.Vod);
        }
      }
      if (mounted) {
        _initTabController();
        setState(() => _homeWidget = _home());
      }
    }
  }

  void _addLiveStreams(List<LiveStream> streams) {
    if (!_tabNodes.contains(TR_LIVE_TV)) {
      _tabNodes.insert(0, TR_LIVE_TV);
      _typesTabView.insert(0, ChannelsTabHomeTV(_channels));
      _initTabController();
      _currentType = _tabNodes.length;
    }

    streams.forEach((channel) {
      bool contains = _containsStream(_channels, channel);
      if (!contains) {
        _channels.add(channel);
      }
    });
  }

  void _addVodStreams(List<VodStream> streams) {
    if (!_tabNodes.contains(TR_VODS)) {
      _tabNodes.insert(0, TR_VODS);
      _typesTabView.insert(0, TVVodPage(_vods));
      _initTabController();
    }

    streams.forEach((stream) {
      bool contains = _containsStream(_vods, stream);
      if (!contains) {
        _vods.add(stream);
      }
    });
  }

  bool _containsStream<U extends IStream>(List<U> list, U add) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].primaryUrl() == add?.primaryUrl()) {
        return true;
      }
    }
    return false;
  }

  void _showExitDialog() async {
    await showDialog(context: context, builder: (BuildContext context) => ExitDialog());
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

  void _onTypeDelete() {
    _currentType = 0;
    if (_channels.isEmpty && widget.vods.isEmpty) {
      _typesTabView.clear();
      _tabNodes.clear();
    } else {
      _typesTabView.removeAt(_currentType);
      _tabNodes.removeAt(_currentType);
    }
    _initTabController();
    setState(() => _homeWidget = _home());
  }
}

class _Tab extends StatelessWidget {
  final String title;

  _Tab(this.title);

  @override
  Widget build(BuildContext context) {
    return Tab(
        child: Text(AppLocalizations.of(context).translate(title),
            style: TextStyle(fontSize: 20, color: Theming.of(context).onBrightness())));
  }
}
