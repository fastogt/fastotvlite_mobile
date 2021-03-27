import 'package:fastotvlite/base/vods/vod_description.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';
import 'package:flutter_fastotv_common/base/vods/vod_description.dart';

class VodDescription extends StatefulWidget {
  final VodStream vod;

  const VodDescription({this.vod});

  VodStream currentVod() {
    return vod;
  }

  @override
  _VodDescriptionState createState() => _VodDescriptionState();
}

class _VodDescriptionState extends State<VodDescription> {
  static const String INVALID_TRAILER_URL =
      "https://fastocloud.com/static/video/invalid_trailer.m3u8";

  @override
  Widget build(BuildContext context) {
    final currentVod = widget.currentVod();

    Widget portrait() {
      return Column(children: <Widget>[
        SizedBox(
            height: 216,
            child: Row(children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                child: SizedBox(width: 180, child: PreviewIcon.vod(currentVod.previewIcon()))
              ),
              const VerticalDivider(),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(children: <Widget>[
                        userScore(currentVod),
                        const Spacer(),
                        trailerButton(currentVod),
                        playButton(currentVod)
                      ])))
            ])),
        const Divider(),
        sideInfo(currentVod),
        const Divider(),
        description(currentVod)
      ]);
    }

    Widget landscape() {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
                width: 196,
                child: Column(children: <Widget>[
                  Expanded(
                      flex: 8,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: PreviewIcon.vod(currentVod.previewIcon())))),
                  trailerButton(currentVod, padding: 8),
                  playButton(currentVod, padding: 8)
                ])),
            const VerticalDivider(),
            Expanded(
                child: Column(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8, 0),
                  child: Row(children: <Widget>[
                    userScore(currentVod),
                    const VerticalDivider(),
                    sideInfo(currentVod)
                  ])),
              const Divider(),
              description(currentVod)
            ]))
          ]);
    }

    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: Theming.of(context).onPrimary()),
            title: Text(AppLocalizations.toUtf8(currentVod.displayName()),
                style: TextStyle(color: Theming.of(context).onPrimary())),
            actions: <Widget>[
              FavoriteStarButton(widget.currentVod().favorite(),
                  onFavoriteChanged: (bool value) => callback(value))
            ]),
        body: OrientationBuilder(builder: (context, orientation) {
          return orientation == Orientation.portrait ? portrait() : landscape();
        }));
  }

  Widget userScore(VodStream currentVod) => UserScore(currentVod.userScore());

  Widget trailerButton(VodStream currentVod, {double padding}) {
    return currentVod.trailerUrl() == INVALID_TRAILER_URL
        ? const Spacer()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: padding ?? 8),
            child: VodTrailerButton(currentVod));
  }

  Widget playButton(VodStream currentVod, {double padding}) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding ?? 8), child: VodPlayButton(currentVod));
  }

  Widget description(VodStream currentVod) {
    return Flexible(child: VodDescriptionText(AppLocalizations.toUtf8(currentVod.description())));
  }

  Widget sideInfo(VodStream currentVod) {
    return SideInfo(
        country: AppLocalizations.toUtf8(currentVod.country()),
        duration: currentVod.duration(),
        primeDate: currentVod.primeDate());
  }

  void callback(bool value) {
    final current = widget.currentVod();
    current.setFavorite(value);
  }
}
