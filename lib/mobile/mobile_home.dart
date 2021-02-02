import 'package:fastotvlite/pages/home_page.dart';
import 'package:fastotvlite/base/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/constants.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/add_streams/add_stream_dialog.dart';
import 'package:fastotvlite/mobile/settings/settings_page.dart';
import 'package:fastotvlite/mobile/streams/live_tab.dart';
import 'package:fastotvlite/mobile/vods/vod_tab.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/logo.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/chromecast/chromecast_info.dart';
import 'package:unicorndial/unicorndial.dart';

class HomeMobile extends HomePage {
  const HomeMobile(List<LiveStream> channels, List<VodStream> vods) : super(channels, vods);

  @override
  _HomeMobileState createState() => _HomeMobileState();
}

class _HomeMobileState extends VideoAppState {
  GlobalKey _liveKey = GlobalKey();
  GlobalKey _vodKey = GlobalKey();

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ChromeCastInfo();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            key: _drawerKey,
            appBar: _appBar(),
            body: _getCurrentTabWidget(),
            drawer: _Drawer(videoTypesList, _setType),
            floatingActionButton: _floatingButton()));
  }

  Widget _getCurrentTabWidget() {
    switch (selectedType) {
      case TR_LIVE_TV:
        return LiveTab(_liveKey, liveStreamsBloc);
      case TR_VODS:
        return VodTab(_vodKey, vodStreamsBloc);

      default:
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(translate(context, TR_NO_STREAMS), softWrap: true)));
    }
  }

  Widget _appBar() {
    double _elevation() {
      if (selectedType == TR_EMPTY) {
        return 4;
      }
      return 0;
    }

    final Color iconColor = Theming.of(context).onCustomColor(Theme.of(context).primaryColor);
    return AppBar(
        elevation: _elevation(),
        iconTheme: IconThemeData(color: iconColor),
        actionsIconTheme: IconThemeData(color: iconColor),
        title: Text(translate(context, selectedType), style: TextStyle(color: iconColor)),
        actions: <Widget>[
          if (selectedType != TR_EMPTY)
            IconButton(icon: Icon(Icons.search), onPressed: _onSearch)
        ]);
  }

  Widget _floatingButton() {
    final _theme = Theme.of(context);
    return UnicornDialer(
        backgroundColor: _theme.primaryColor.withOpacity(0.4),
        parentButtonBackground: _theme.accentColor,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: [
          _dialAction(TR_SINGLE_STREAM, "single", PickStreamFrom.SINGLE_STREAM, Icons.add_to_queue),
          _dialAction(TR_PLAYLIST, "playlist", PickStreamFrom.PLAYLIST, Icons.playlist_add)
        ]);
  }

  Widget _dialAction(String title, String tag, PickStreamFrom source, IconData icon) {
    return UnicornButton(
        labelColor: Theming.of(context).onBrightness(),
        labelBackgroundColor: Colors.transparent,
        labelText: translate(context, title),
        labelHasShadow: false,
        hasLabel: true,
        currentButton: FloatingActionButton(
            heroTag: tag,
            backgroundColor: Theme.of(context).accentColor,
            mini: true,
            onPressed: () => _onAdd(source),
            child: Icon(icon)));
  }

  void _onAdd(PickStreamFrom source) async {
    AddStreamResponse response = await showDialog(
        context: context, builder: (BuildContext context) => FilePickerDialog(source));
    if (response == null) {
      _drawerKey.currentState.showSnackBar(SnackBar(
          content: Text(translate(context, TR_NO_CHANNELS_ADDED)),
          action: SnackBarAction(
              label: translate(context, TR_CLOSE),
              onPressed: () => _drawerKey.currentState.hideCurrentSnackBar())));
    } else {
      addStreams(response);
    }
  }

  void _onSearch() async {
    final result = await showSearch(context: context, delegate: searchDelegate);
    if (result != null) {
      sendSearchEvent(result);
    }
  }

  void _setType(String type) {
    setState(() => selectedType = type);
  }
}

class _Drawer extends StatelessWidget {
  final List<String> videoTypesList;
  final void Function(String) onType;

  const _Drawer(this.videoTypesList, this.onType);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      const DrawerHeader(child: Center(child: CircleAssetLogo(LOGO_PATH))),
      ..._drawerTiles(context),
      const Divider(),
      _SettingsTile()
    ]));
  }

  List<Widget> _drawerTiles(BuildContext context) {
    final iconColor = Theming.of(context).onBrightness();
    return List<ListTile>.generate(videoTypesList.length, (int index) {
      final type = videoTypesList[index];
      final title = translate(context, type);
      final icon = _iconFromType(type);
      return ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title),
          onTap: () {
            Navigator.of(context).pop();
            onType(videoTypesList[index]);
          });
    });
  }

  IconData _iconFromType(String type) {
    if (type == TR_LIVE_TV) {
      return Icons.personal_video;
    } else if (type == TR_VODS) {
      return Icons.ondemand_video;
    }
    return Icons.warning;
  }
}

class _SettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.settings, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_SETTINGS)),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));
        });
  }
}
