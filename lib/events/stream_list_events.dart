import 'package:event_bus/event_bus.dart';

class StreamListEvent {
  static Future<StreamListEvent> getInstance() async {
    if (_instance == null) {
      _instance = StreamListEvent();
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
  static StreamListEvent _instance;
  final _bus = EventBus(sync: true);
}
