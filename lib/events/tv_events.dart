import 'package:event_bus/event_bus.dart';

class TvTabsEvents {
  static Future<TvTabsEvents> getInstance() async {
    _instance ??= TvTabsEvents();
    return _instance!;
  }

  void publish(dynamic event) {
    _bus.fire(event);
  }

  Stream<T> subscribe<T>() {
    return _bus.on<T>();
  }

  // private:
  static TvTabsEvents? _instance;
  final _bus = EventBus(sync: true);
}

class OpenedTvSettings {
  final bool value;

  OpenedTvSettings(this.value);
}

class ClockFormatChanged {
  final bool hour24;

  ClockFormatChanged(this.hour24);
}

class TvGuideSwitch {
  final bool onScroll;

  TvGuideSwitch(this.onScroll);
}
