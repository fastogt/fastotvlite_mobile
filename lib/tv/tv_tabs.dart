import 'package:fastotvlite/base/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/base/tabbar.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/constants.dart';
import 'package:fastotvlite/events/tv_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/notification.dart';
import 'package:fastotvlite/pages/home_page.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/add_streams/tv_add_stream_dialog.dart';
import 'package:fastotvlite/tv/add_streams/tv_stream_quantity.dart';
import 'package:fastotvlite/tv/exit_dialog.dart';
import 'package:fastotvlite/tv/search_page.dart';
import 'package:fastotvlite/tv/settings/tv_settings_page.dart';
import 'package:fastotvlite/tv/streams/tv_live_tab.dart';
import 'package:fastotvlite/tv/vods/tv_vod_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/widgets.dart';

class HomeTV extends HomePage {
  const HomeTV(List<LiveStream> channels, List<VodStream> vods) : super(channels, vods);

  @override
  _HomeTVState createState() => _HomeTVState();
}

const TABBAR_HEIGHT = 72;

class _HomeTVState extends VideoAppState with TickerProviderStateMixin {
  TabController _tabController;
  bool isVisible = true;

  double _scale;

  String get _currentCategory => videoTypesList[_tabController.index];

  List get _currentStreams {
    switch (_currentCategory) {
      case TR_LIVE_TV:
        return channels();
      case TR_VODS:
        return vods();
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _scale = settings.screenScale();
    _initTabController();
  }

  @override
  void dispose() {
    _closeTabController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: NotificationListener<TvChannelNotification>(
            onNotification: (notification) {
              switch (notification.title) {
                case NotificationTypeTV.FULLSCREEN:
                  setState(() {
                    isVisible = notification.visibility;
                  });
                  if (!isVisible) {
                    FocusScope.of(context).unfocus();
                  }
                  break;
                default:
              }
              return true;
            },
            child: FractionallySizedBox(
                widthFactor: _scale,
                heightFactor: _scale,
                child: Scaffold(
                    body: Column(children: <Widget>[
                      Visibility(
                          visible: isVisible,
                          child: IconTheme(
                              data: IconThemeData(color: Theming.of(context).onBrightness()),
                              child: AppBar(
                                  leading: const Padding(
                                      padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                                      child: CustomAssetLogo(LOGO_PATH)),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  title: Row(children: <Widget>[
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: SingleChildScrollView(
                                            child: TabBarEx(_tabController, videoTypesList)))
                                  ]),
                                  actions: <Widget>[
                                    if (selectedType != TR_EMPTY)
                                      IconButton(icon: const Icon(Icons.search),
                                          onPressed: _onSearch),
                                    IconButton(icon: const Icon(Icons.add_circle),
                                        onPressed: _onAdd),
                                    IconButton(
                                        icon: const Icon(Icons.settings), onPressed: _toSettings),
                                    IconButton(
                                        icon: const Icon(Icons.power_settings_new),
                                        onPressed: _showExitDialog),
                                    _clock()
                                  ]))),
                      Expanded(child: _getCurrentTabWidget())
                    ])))));
  }

  Widget _getCurrentTabWidget() {
    switch (selectedType) {
      case TR_LIVE_TV:
        return ChannelsTabHomeTV(liveStreamsBloc);
      case TR_VODS:
        return TVVodPage(vodStreamsBloc);

      default:
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(translate(TR_NO_STREAMS), softWrap: true)));
    }
  }

  Widget _clock() {
    final settings = locator<LocalStorageService>();
    final _initFormat = settings.timeFormat();
    final tvTabsEvents = locator<TvTabsEvents>();
    final color = Theming.of(context).onBrightness();
    return StreamBuilder<ClockFormatChanged>(
        initialData: ClockFormatChanged(_initFormat),
        stream: tvTabsEvents.subscribe<ClockFormatChanged>(),
        builder: (context, snapshot) =>
            Clock.full(textColor: color, hour24: snapshot.data.hour24));
  }

  void _initTabController() {
    final _initIndex = videoTypesList.indexOf(selectedType);
    _tabController = TabController(
        vsync: this, length: videoTypesList.length, initialIndex: _initIndex < 0 ? 0 : _initIndex);
    _tabController.addListener(_updateSelected);
  }

  void _closeTabController() {
    _tabController.removeListener(_updateSelected);
    _tabController.dispose();
  }

  void _updateSelected() {
    setState(() {
      selectedType = videoTypesList[_tabController.index];
    });
  }

  void _onSearch() async {
    final tvTabsEvents = locator<TvTabsEvents>();
    tvTabsEvents.publish(OpenedTvSettings(true));
    final stream = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SearchPage(_currentStreams)));
    tvTabsEvents.publish(OpenedTvSettings(false));
    if (stream != null) {
      sendSearchEvent(stream);
    }
  }

  void _toSettings() async {
    final tvTabsEvents = locator<TvTabsEvents>();
    tvTabsEvents.publish(OpenedTvSettings(true));
    final double padding = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingPageTV()));
    tvTabsEvents.publish(OpenedTvSettings(false));
    setState(() => _scale = padding);
  }

  void _onAdd() async {
    final PickStreamFrom _source = await showDialog(
        context: context, builder: (BuildContext context) => const StreamTypePickerTV());
    if (_source != null) {
      final AddStreamResponse response = await showDialog(
          context: context, builder: (BuildContext context) => FilePickerDialogTV(_source));
      if (response != null) {
        addStreams(response);
        _initTabController();
        setState(() {});
      }
    }
  }

  @override
  void onTypeDelete() {
    super.onTypeDelete();
    _initTabController();
    setState(() {});
  }

  void _showExitDialog() async {
    await showDialog(context: context, builder: (BuildContext context) => ExitDialog());
  }
}
