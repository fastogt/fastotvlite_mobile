import 'package:fastotvlite/base/vods/vod_description.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/vods/tv_vod_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/base/controls/favorite_button.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/scroll_controller_manager.dart';
import 'package:flutter_common/tv/key_code.dart';
import 'package:flutter_fastotv_common/base/vods/vod_card.dart';
import 'package:flutter_fastotv_common/base/vods/vod_description.dart';

class TvVodDescription extends StatefulWidget {
  TvVodDescription({this.channel});

  final VodStream channel;

  @override
  _TvVodDescriptionState createState() => _TvVodDescriptionState();
}

class _TvVodDescriptionState extends State<TvVodDescription> {
  static const DESCRIPTION_FONT_SIZE = 20.0;
  static const INFO_FONT_SIZE = 20.0;

  FocusScopeNode descriptionScope = FocusScopeNode();
  FocusNode descriptionNode = FocusNode();
  CustomScrollController descriptionController = CustomScrollController(itemHeight: DESCRIPTION_FONT_SIZE);
  FocusNode infoNode = FocusNode();
  CustomScrollController infoController = CustomScrollController(itemHeight: DESCRIPTION_FONT_SIZE);
  FocusNode backButtonNode = FocusNode();
  FocusNode posterNode = FocusNode();
  FocusNode playNode = FocusNode();
  FocusNode trailerNode = FocusNode();
  FocusNode favoriteNode = FocusNode();
  int index = 0;

  Color get activeColor => Theme.of(context).accentColor;

  double _scaleFactor = 1;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _scaleFactor = settings.screenScale();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusBackButton();
    });
  }

  BoxBorder border(FocusNode focus) =>
      Border.all(color: focus.hasPrimaryFocus ? activeColor : Colors.transparent, width: 2);

  Color buttonColor(FocusNode node) => node.hasPrimaryFocus ? activeColor : Theming.of(context).onPrimary();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: FocusScope(
          onKey: _backAction,
          node: descriptionScope,
          child: FractionallySizedBox(
            widthFactor: _scaleFactor,
            heightFactor: _scaleFactor,
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: Text(AppLocalizations.toUtf8(widget.channel.displayName()),
                      style: TextStyle(color: Theming.of(context).onBrightness())),
                  leading: _backButton(),
                  actions: <Widget>[_playButton(), _trailerButton(), _starButton()]),
              body: Padding(
                  padding: EdgeInsets.all(16.0 * _scaleFactor),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(8.0 * _scaleFactor),
                          child: Row(children: <Widget>[
                            _score(),
                            VerticalDivider(color: Colors.white),
                            _info(),
                          ])),
                      Row(children: <Widget>[_poster(), SizedBox(width: 16), _description()])
                    ])
                  ])),
            ),
          )),
    );
  }

  Widget _backButton() => Focus(
      focusNode: backButtonNode,
      onKey: _onBackButton,
      child: IconButton(
          icon: Icon(Icons.arrow_back), iconSize: 32, color: buttonColor(backButtonNode), onPressed: () => _goBack()));

  Widget _playButton() => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Focus(
          focusNode: playNode,
          onKey: _onPlayButton,
          child: VodPlayButton(widget.channel, context, color: buttonColor(playNode))));

  Widget _trailerButton() => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Focus(
          focusNode: trailerNode,
          onKey: _onTrailerButton,
          child: VodTrailerButton(widget.channel, context, color: buttonColor(trailerNode))));

  Widget _starButton() => Focus(
      focusNode: favoriteNode,
      onKey: _onFavoriteButton,
      child: FavoriteStarButton(widget.channel.favorite(),
          unselectedColor: buttonColor(favoriteNode), selectedColor: buttonColor(favoriteNode)));

  Widget _score() => UserScore(widget.channel.userScore(), fontSize: INFO_FONT_SIZE * _scaleFactor);

  Widget _info() => Focus(
      onKey: _onInfo,
      focusNode: infoNode,
      child: Container(
          decoration: BoxDecoration(border: border(infoNode)),
          child: SideInfo(
              country: AppLocalizations.toUtf8(widget.channel.country()),
              duration: widget.channel.duration(),
              primeDate: widget.channel.primeDate(),
              fontSize: INFO_FONT_SIZE * _scaleFactor,
              scrollController: infoController.controller)));

  Widget _poster() => Focus(
      focusNode: posterNode,
      onKey: _onPoster,
      child: Container(
          decoration: BoxDecoration(border: border(posterNode)),
          child: VodCard(
              width: 196 * _scaleFactor,
              iconLink: widget.channel.icon(),
              duration: widget.channel.duration(),
              interruptTime: widget.channel.interruptTime())));

  Widget _description() => Focus(
      focusNode: descriptionNode,
      onKey: _onDescription,
      child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 196 * 3 / 2 * _scaleFactor,
          decoration: BoxDecoration(border: border(descriptionNode)),
          child: VodDescriptionText(AppLocalizations.toUtf8(widget.channel.description()),
              textSize: DESCRIPTION_FONT_SIZE * _scaleFactor, scrollController: descriptionController.controller)));

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _focusBackButton() {
    FocusScope.of(context).requestFocus(backButtonNode);
  }

  bool _onBackButton(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_CENTER:
        case ENTER:
          _goBack();
          break;

        case KEY_DOWN:
          descriptionScope.requestFocus(posterNode);
          break;

        case KEY_RIGHT:
          descriptionScope.requestFocus(playNode);
          break;

        case KEY_RIGHT:
          descriptionScope.requestFocus(favoriteNode);
          break;

        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool _onPlayButton(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_CENTER:
        case ENTER:
          _onPlayTapped();
          break;

        case KEY_DOWN:
          descriptionScope.requestFocus(infoNode);
          break;
        case KEY_LEFT:
          descriptionScope.requestFocus(backButtonNode);
          break;
        case KEY_RIGHT:
          descriptionScope.requestFocus(trailerNode);
          break;

        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  void _onPlayTapped() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TvVodPlayerPage(widget.channel);
    }));
    descriptionScope.requestFocus(playNode);
  }

  bool _onTrailerButton(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_CENTER:
          break;
        case ENTER:
          break;

        case KEY_DOWN:
          descriptionScope.requestFocus(infoNode);
          break;
        case KEY_LEFT:
          descriptionScope.requestFocus(playNode);
          break;
        case KEY_RIGHT:
          descriptionScope.requestFocus(favoriteNode);
          break;

        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool _onFavoriteButton(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_CENTER:
        case ENTER:
          handleFavorite();
          break;

        case KEY_DOWN:
          descriptionScope.requestFocus(infoNode);
          break;
        case KEY_LEFT:
          descriptionScope.requestFocus(trailerNode);
          break;
        case KEY_RIGHT:
          descriptionScope.requestFocus(backButtonNode);
          break;

        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool _onPoster(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_UP:
          descriptionScope.requestFocus(backButtonNode);
          break;
        case KEY_RIGHT:
          descriptionScope.requestFocus(descriptionNode);
          break;
        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool _onInfo(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_LEFT:
          infoController.moveUp();
          break;
        case KEY_RIGHT:
          infoController.moveDown();
          break;
        case KEY_DOWN:
          infoController.moveToTop();
          descriptionScope.requestFocus(descriptionNode);
          break;
        case KEY_UP:
          infoController.moveToTop();
          descriptionScope.requestFocus(backButtonNode);
          break;

        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool _onDescription(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case KEY_LEFT:
          if (widget.channel.description().isNotEmpty) {
            descriptionController.moveToTop();
          }
          descriptionScope.requestFocus(posterNode);
          break;
        case KEY_DOWN:
          if (widget.channel.description().isNotEmpty) {
            descriptionController.moveDown();
          }
          break;
        case KEY_UP:
          if (widget.channel.description().isEmpty) {
            descriptionScope.requestFocus(infoNode);
            break;
          }
          if (descriptionController.controller.offset == 0.0) {
            descriptionScope.requestFocus(infoNode);
            break;
          }
          descriptionController.moveUp();
          break;
        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  bool _backAction(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case BACK:
        case BACKSPACE:
          _goBack();
          break;
        default:
          break;
      }
      setState(() {});
    }
    return node.hasPrimaryFocus;
  }

  void handleFavorite() {
    final current = widget.channel;
    final favorite = current.favorite();
    current.setFavorite(!favorite);
  }
}
