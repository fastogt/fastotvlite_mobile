import 'package:fastotvlite/base/tv/snackbar.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:player/controller.dart';
import 'package:player/widgets/player.dart';

abstract class PlayerPageTVState<T extends StatefulWidget> extends State<T> {
  bool isVisible = true;
  FocusNode playerFocus = FocusNode();
  bool _isSnackBarActive = false;

  PlayerController get controller;

  String get name;

  void initPlayer();

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    final _scale = settings.screenScale();
    return FractionallySizedBox(
        widthFactor: _scale,
        heightFactor: _scale,
        child: Scaffold(body: Builder(builder: (context) {
          return Focus(
              autofocus: true,
              onKey: (FocusNode node, RawKeyEvent event) => onPlayer(event, context),
              focusNode: playerFocus,
              child: LitePlayer(controller: controller));
        })));
  }

  void showSnackBar(BuildContext ctx, bool show) {
    if (show == _isSnackBarActive) {
      return;
    }

    if (show) {
      final snack = PlayerSnackbarTV(context, name, controller.isPlaying());
      _isSnackBarActive = true;
      ScaffoldMessenger.of(ctx).showSnackBar(snack).closed.then((_) {
        _isSnackBarActive = false;
      });
    } else {
      ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    }
  }

  KeyEventResult onPlayer(RawKeyEvent event, BuildContext ctx);

  void onEnter(BuildContext context) {
    if (controller.isPlaying()) {
      controller.pause();
    } else {
      controller.play();
    }
    showSnackBar(context, !_isSnackBarActive);
  }

  void toggleSnackBar(BuildContext context) {
    showSnackBar(context, !_isSnackBarActive);
  }
}
