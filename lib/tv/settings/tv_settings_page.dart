import 'dart:async';

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
import 'package:flutter/services.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/tv/key_code.dart';

Color borderColor(BuildContext context, bool condition) {
  if (condition) {
    return Theme.of(context).accentColor;
  }
  return Colors.transparent;
}

class SettingPageTV extends StatefulWidget {
  SettingPageTV({this.login, this.expDate, this.deviceID});

  final String login;
  final DateTime expDate;
  final String deviceID;

  @override
  _SettingPageTVState createState() => _SettingPageTVState();
}

class _SettingPageTVState extends State<SettingPageTV> {
  static const LIST_ITEM_SIZE = 60.0;

  int currentType = 0;
  FocusNode categoriesList = FocusNode();
  FocusNode settingsList = FocusNode();
  FocusNode backButtonNode = FocusNode();
  FocusScopeNode settingsScope = FocusScopeNode();

  double _scale;
  StreamController paddingCallback = StreamController();

  static const ITEM_LIST = [TR_PARENTAL_CONTROL, TR_THEME, TR_SCREEN_SIZE, TR_LANGUAGE, TR_TIME_FORMAT];

  Widget _getCurrentSetting(int current) {
    switch (current) {
      case 0:
        return AgePickerTV(settingsList, () => _toCategories());
      case 1:
        return ThemePickerTV(settingsList, () => _toCategories(), Theming.of(context).themeId);
      case 2:
        return PaddingSettings(settingsList, () => _toCategories(), paddingCallback);
      case 3:
        return LanguagePickerTV(settingsList, () => setState(() {}));
      case 4:
        return ClockFormatPickerTV(settingsList, () => setState(() {}));
      default:
        return Icon(Icons.info);
    }
  }

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _scale = settings.screenScale();
    paddingCallback.stream.listen((data) {
      _setPadding(data);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      settingsScope.requestFocus(categoriesList);
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    settingsScope.unfocus();
    paddingCallback.close();
  }

  @override
  Widget build(BuildContext context) {
    Color getDecoration(FocusNode focus, int comparing, int index) {
      if ((focus.hasFocus || focus.hasPrimaryFocus) && comparing == index) {
        return Theme.of(context).accentColor;
      }

      if (index == comparing) {
        return Colors.grey;
      }
      return Colors.transparent;
    }

    final textStyle = TextStyle(fontSize: 20);
    final availableWidth = MediaQuery.of(context).size.width * _scale;
    final categoriesWidth = availableWidth / 4;
    final sideFieldsWidth = (availableWidth - categoriesWidth) / 2;
    final listHeight = LIST_ITEM_SIZE * ITEM_LIST.length;
    final verticalDivider = Container(height: listHeight, child: VerticalDivider(width: 0));
    return FocusScope(
        node: settingsScope,
        child: FractionallySizedBox(
            widthFactor: _scale,
            heightFactor: _scale,
            child: Stack(children: <Widget>[
              Scaffold(
                  appBar: AppBar(
                      leading: _backButton(),
                      elevation: 0,
                      title: Text(AppLocalizations.of(context).translate(TR_SETTINGS),
                          style: TextStyle(color: Theming.of(context).onCustomColor(Theme.of(context).primaryColor))),
                      centerTitle: true),
                  body: Container(
                      color: Theme.of(context).primaryColor,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: sideFieldsWidth,
                                child: Center(
                                    child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 96.0,
                                        child: Image.asset(LOGO_PATH)))),
                            verticalDivider,
                            Focus(
                                focusNode: categoriesList,
                                onKey: _onCategories,
                                child: Container(
                                    width: categoriesWidth,
                                    height: LIST_ITEM_SIZE * ITEM_LIST.length,
                                    child: ListView.builder(
                                        itemCount: ITEM_LIST.length,
                                        itemExtent: LIST_ITEM_SIZE,
                                        itemBuilder: (context, index) => Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: getDecoration(categoriesList, currentType, index),
                                                    width: 2)),
                                            child: ListTile(
                                                title: Text(AppLocalizations.of(context).translate(ITEM_LIST[index]),
                                                    style: textStyle)))))),
                            verticalDivider,
                            Container(
                                width: sideFieldsWidth,
                                height: LIST_ITEM_SIZE * ITEM_LIST.length,
                                constraints: new BoxConstraints(
                                  minHeight: LIST_ITEM_SIZE * 5.0,
                                ),
                                child: Center(child: _getCurrentSetting(currentType)))
                          ]))),
              paddingSetupContainer(),
              paddingSetupContainer(right: 0),
              paddingSetupContainer(bottom: 0),
              paddingSetupContainer(bottom: 0, right: 0)
            ])));
  }

  Widget _backButton() {
    Color buttonColor(FocusNode node) {
      return node.hasPrimaryFocus
          ? Theme.of(context).accentColor
          : Theming.of(context).onCustomColor(Theme.of(context).primaryColor);
    }

    return Focus(
        focusNode: backButtonNode,
        onKey: _onBack,
        child: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 32,
            color: buttonColor(backButtonNode),
            onPressed: () {
              _goBack();
            }));
  }

  Widget paddingSetupContainer({double right, double bottom}) {
    Color color = settingsList.hasPrimaryFocus && ITEM_LIST[currentType] == TR_SCREEN_SIZE
        ? Colors.redAccent
        : Colors.transparent;
    return Positioned(right: right, bottom: bottom, child: Container(color: color, width: 24, height: 24));
  }

  void _nextCategory() {
    if (currentType == ITEM_LIST.length - 1) {
      currentType = 0;
    } else {
      currentType++;
    }
  }

  void _prevCategory() {
    if (currentType == 0) {
      currentType = ITEM_LIST.length - 1;
    } else {
      currentType--;
    }
  }

  void _goBack() {
    Navigator.of(context).pop(_scale);
  }

  void _toPassword() async {
    bool passed = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AgePickerPassword()));
    if (passed) {
      settingsList.requestFocus();
    } else {
      categoriesList.requestFocus();
    }
  }

  bool _onCategories(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
        case KEY_RIGHT:
          if (currentType == 0) {
            _toPassword();
          } else {
            settingsList.requestFocus();
          }
          break;

        case BACKSPACE:
        case BACK:
          {
            _goBack();
            break;
          }

        case KEY_UP:
          {
            _prevCategory();
            break;
          }
        case KEY_DOWN:
          {
            _nextCategory();
            break;
          }

        case KEY_LEFT:
          {
            settingsScope.requestFocus(backButtonNode);
            break;
          }

        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool _onBack(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          _goBack();
          break;
        case KEY_RIGHT:
          settingsScope.requestFocus(categoriesList);
          break;
        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  void _toCategories() {
    settingsList.unfocus();
    categoriesList.requestFocus();
    setState(() {});
  }

  void _setPadding(double value) {
    _scale = value;
    setState(() {});
  }
}
