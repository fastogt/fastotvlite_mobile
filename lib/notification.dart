import 'package:flutter/material.dart';

/// EXAMPLE
/// ControlsNotification(title: "Next")..dispatch(context);

enum NotificationType {
  ///TV page tab controller
  TO_CATEGORY,
  TO_CHANNELS,
  TO_TABS,
  TO_SETTINGS,
  EXIT_SETTINGS,

  /// VideoPlayer controller
  PLAY_PAUSE,
  NEXT_CHANNEL,
  PREV_CHANNEL,
  NEXT_CATEGORY,
  PREV_CATEGORY,
  FULLSCREEN
}

class TvChannelNotification extends Notification {
  final NotificationType title;
  final bool visibility;

  const TvChannelNotification({this.title, this.visibility});
}

class PlayerNotification extends Notification {
  final NotificationType title;

  const PlayerNotification({this.title});
}
