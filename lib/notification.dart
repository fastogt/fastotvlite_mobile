import 'package:flutter/material.dart';

/// EXAMPLE
/// ControlsNotification(title: "Next")..dispatch(context);

enum NotificationTypeTV {
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
  final NotificationTypeTV title;
  final bool visibility;

  const TvChannelNotification({required this.title, required this.visibility});
}

class PlayerNotification extends Notification {
  final NotificationTypeTV title;

  const PlayerNotification({required this.title});
}
