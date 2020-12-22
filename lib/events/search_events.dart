import 'package:event_bus/event_bus.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';

class SearchEvents {
  static Future<SearchEvents> getInstance() async {
    if (_instance == null) {
      _instance = SearchEvents();
    }
    return _instance;
  }

  void publish(dynamic event) {
    _bus.fire(event);
  }

  Stream<T> subscribe<T>() {
    return _bus.on<T>();
  }

  // private:
  static SearchEvents _instance;
  final _bus = EventBus(sync: true);
}

class SearchEvent<T extends IStream> {
  final T stream;

  SearchEvent(this.stream);
}

class LiveSearchEvent {
  final LiveStream stream;

  LiveSearchEvent(this.stream);
}

class VodSearchEvent {
  final VodStream stream;

  VodSearchEvent(this.stream);
}
