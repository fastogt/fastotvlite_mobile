import 'package:event_bus/event_bus.dart';

class SearchEvents {
  static Future<SearchEvents> getInstance() async {
    _instance ??= SearchEvents();
    return _instance!;
  }

  void publish(dynamic event) {
    _bus.fire(event);
  }

  Stream<T> subscribe<T>() {
    return _bus.on<T>();
  }

  // private:
  static SearchEvents? _instance;
  final _bus = EventBus(sync: true);
}

class StreamSearchEvent<T> {
  final T stream;

  StreamSearchEvent(this.stream);
}
