import 'package:fastotvlite/base/focusable/actions.dart';
import 'package:fastotvlite/base/focusable/border.dart';
import 'package:fastotvlite/base/vods/vod_description.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/vods/tv_vod_edit_channel.dart';
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
  const TvVodDescription(this.channel);

  final VodStream channel;

  @override
  _TvVodDescriptionState createState() => _TvVodDescriptionState();
}

class _TvVodDescriptionState extends State<TvVodDescription> {
  static const DESCRIPTION_FONT_SIZE = 20.0;
  static const INFO_FONT_SIZE = 20.0;

  FocusNode descriptionNode = FocusNode();
  CustomScrollController descriptionController =
      CustomScrollController(itemHeight: DESCRIPTION_FONT_SIZE);
  FocusNode infoNode = FocusNode();
  CustomScrollController infoController = CustomScrollController(itemHeight: DESCRIPTION_FONT_SIZE);
  FocusNode backButtonNode = FocusNode();
  FocusNode posterNode = FocusNode();
  FocusNode playNode = FocusNode();
  FocusNode trailerNode = FocusNode();
  FocusNode favoriteNode = FocusNode();
  int index = 0;

  Color get activeColor => Theming.of(context).theme.accentColor;

  double _scaleFactor = 1;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    _scaleFactor = settings.screenScale();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: _scaleFactor,
        heightFactor: _scaleFactor,
        child: Scaffold(
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
                          const VerticalDivider(color: Colors.white),
                          _info(),
                        ])),
                    Row(children: <Widget>[_poster(), const SizedBox(width: 16), _description()])
                  ])
                ]))));
  }

  Widget _backButton() {
    return IconButton(
        autofocus: true,
        focusNode: backButtonNode,
        icon: const Icon(Icons.arrow_back),
        color: Theming.of(context).onBrightness(),
        onPressed: Navigator.of(context).pop);
  }

  Widget _playButton() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            width: 96,
            child: VodPlayButton(widget.channel, onTap: _onPlayTapped, focus: playNode)));
  }

  Widget _trailerButton() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: VodTrailerButton(widget.channel, focus: trailerNode));
  }

  Widget _starButton() {
    return FavoriteStarButton(widget.channel.favorite(),
        focusNode: favoriteNode, unselectedColor: Theming.of(context).onBrightness());
  }

  Widget _score() {
    return UserScore(widget.channel.userScore(), fontSize: INFO_FONT_SIZE * _scaleFactor);
  }

  Widget _info() {
    return Focus(
        onKey: _onInfo,
        focusNode: infoNode,
        child: FocusBorder(
            focus: infoNode,
            child: SideInfo(
                country: AppLocalizations.toUtf8(widget.channel.country() ?? ''),
                duration: widget.channel.duration(),
                primeDate: widget.channel.primeDate(),
                fontSize: INFO_FONT_SIZE * _scaleFactor,
                scrollController: infoController.controller)));
  }

  Widget _poster() {
    return Focus(
        focusNode: posterNode,
        onKey: (node, event) {
          return onKeyArrows(context, event);
        },
        child: FocusBorder(
            focus: posterNode,
            child: InkWell(
                child: VodCard(
                    width: 196 * _scaleFactor,
                    iconLink: widget.channel.icon(),
                    duration: widget.channel.duration(),
                    interruptTime: widget.channel.interruptTime()))));
  }

  Widget _description() {
    return Focus(
        focusNode: descriptionNode,
        onKey: _onDescription,
        child: FocusBorder(
            focus: descriptionNode,
            child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: 196 * 3 / 2 * _scaleFactor,
                child: DescriptionText(
                  AppLocalizations.toUtf8(widget.channel.description()),
                  textSize: DESCRIPTION_FONT_SIZE * _scaleFactor,
                  scrollController: descriptionController.controller,
                  textColor: Theming.of(context).onBrightness(),
                ))));
  }

  void _onPlayTapped() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TvVodPlayerPage(widget.channel);
    }));
    FocusScope.of(context).requestFocus(playNode);
  }

  bool _onInfo(FocusNode node, RawKeyEvent event) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KEY_LEFT:
          infoController.moveUp();
          return true;
        case KEY_RIGHT:
          infoController.moveDown();
          return true;
        case KEY_DOWN:
          infoController.moveToTop();
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          return true;
        case KEY_UP:
          infoController.moveToTop();
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          return true;
      }
      return false;
    });
  }

  bool _onDescription(FocusNode node, RawKeyEvent event) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KEY_LEFT:
          if (widget.channel.description().isNotEmpty) {
            descriptionController.moveToTop();
          }
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          return true;
        case KEY_DOWN:
          if (widget.channel.description().isNotEmpty) {
            descriptionController.moveDown();
          }
          return true;
        case KEY_UP:
          if (widget.channel.description().isEmpty) {
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
            return true;
          }
          if (descriptionController.controller.offset == 0.0) {
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
            return true;
          }
          descriptionController.moveUp();
          return true;
      }
      return false;
    });
  }
}
