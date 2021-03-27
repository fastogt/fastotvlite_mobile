import 'package:fastotvlite/base/tv/constants.dart';
import 'package:fastotvlite/constants.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/settings/tv_age_picker.dart';
import 'package:fastotvlite/tv/settings/tv_language_picker.dart';
import 'package:fastotvlite/tv/settings/tv_padding.dart';
import 'package:fastotvlite/tv/settings/tv_theming.dart';
import 'package:fastotvlite/tv/settings/tv_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class SettingPageTV extends StatefulWidget {
  const SettingPageTV();

  @override
  _SettingPageTVState createState() => _SettingPageTVState();
}

class _SettingPageTVState extends State<SettingPageTV> {
  int currentType = 0;
  FocusNode settingsList = FocusNode();

  double _scale;

  static const ITEM_LIST = [
    TR_PARENTAL_CONTROL,
    TR_THEME,
    TR_SCREEN_SIZE,
    TR_LANGUAGE,
    TR_TIME_FORMAT
  ];

  Widget _getCurrentSetting(int current) {
    switch (current) {
      case 0:
        return const AgePickerTV();
      case 1:
        return ThemePickerTV(Theming
            .of(context)
            .themeId);
      case 2:
        return PaddingSettings(_setPadding);
      case 3:
        return const LanguagePickerTV();
      case 4:
        return const ClockFormatPickerTV();
      default:
        return const Icon(Icons.info);
    }
  }

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _scale = settings.screenScale();
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery
        .of(context)
        .size
        .width * _scale;
    final categoriesWidth = availableWidth / 4;
    final sideFieldsWidth = (availableWidth - categoriesWidth) / 2;
    final listHeight = TV_LIST_ITEM_SIZE * ITEM_LIST.length;
    final verticalDivider = SizedBox(height: listHeight, child: const VerticalDivider(width: 0));
    return FractionallySizedBox(
        widthFactor: _scale,
        heightFactor: _scale,
        child: Stack(children: <Widget>[
          Scaffold(
              appBar: AppBar(
                  backgroundColor: Theme
                      .of(context)
                      .scaffoldBackgroundColor,
                  leading: _backButton(),
                  elevation: 0,
                  title: Text(AppLocalizations.of(context).translate(TR_SETTINGS),
                      style: TextStyle(color: Theming.of(context).onBrightness())),
                  centerTitle: true),
              body: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                SizedBox(
                    width: sideFieldsWidth,
                    child: Center(
                        child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 96.0,
                            child: Image.asset(LOGO_PATH)))),
                verticalDivider,
                SizedBox(
                    width: categoriesWidth,
                    height: listHeight,
                    child: NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowGlow();
                          return true;
                        },
                        child: ListView.builder(
                            itemCount: ITEM_LIST.length,
                            itemExtent: TV_LIST_ITEM_SIZE,
                            itemBuilder: (context, index) {
                              return _SettingsTile(
                                  title: ITEM_LIST[index],
                                  onFocus: () {
                                    currentType = index;
                                    setState(() {});
                                  });
                            }))),
                verticalDivider,
                Container(
                    width: sideFieldsWidth,
                    height: listHeight,
                    constraints: const BoxConstraints(minHeight: TV_LIST_ITEM_SIZE * 5.0),
                    child: Center(child: _getCurrentSetting(currentType)))
              ])),
          paddingSetupContainer(),
          paddingSetupContainer(right: 0),
          paddingSetupContainer(bottom: 0),
          paddingSetupContainer(bottom: 0, right: 0)
        ]));
  }

  Widget _backButton() {
    return IconButton(
        icon: Icon(Icons.arrow_back, color: Theming.of(context).onBrightness()),
        iconSize: 32,
        onPressed: _goBack);
  }

  Widget paddingSetupContainer({double right, double bottom}) {
    final Color color = settingsList.hasPrimaryFocus && ITEM_LIST[currentType] == TR_SCREEN_SIZE
        ? Colors.redAccent
        : Colors.transparent;
    return Positioned(
        right: right, bottom: bottom, child: Container(color: color, width: 24, height: 24));
  }

  void _goBack() {
    Navigator.of(context).pop(_scale);
  }

  void _setPadding(double value) {
    _scale = value;
    setState(() {});
  }
}

class _SettingsTile extends StatefulWidget {
  final String title;
  final void Function() onFocus;

  const _SettingsTile({@required this.title, @required this.onFocus});

  @override
  _SettingsTileState createState() {
    return _SettingsTileState();
  }
}

class _SettingsTileState extends State<_SettingsTile> {
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
        onKey: (node, event) {
          return onKeyArrows(context, event);
        },
        child: Stack(children: <Widget>[_background(), _tile()]));
  }

  // private:
  Widget _background() {
    return Container(color: _backgroundColor());
  }

  Widget _tile() {
    return ListTile(
        title: Text(AppLocalizations.of(context).translate(widget.title),
            style: const TextStyle(fontSize: 20), maxLines: 2, overflow: TextOverflow.ellipsis));
  }

  Color _backgroundColor() {
    if (!_node.hasFocus) {
      return Colors.transparent;
    }

    return Theme
        .of(context)
        .focusColor;
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      widget.onFocus();
    }
    setState(() {});
  }
}
