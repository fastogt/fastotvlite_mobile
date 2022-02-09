import 'package:event_bus/event_bus.dart';

class ClientEvents {
  static Future<ClientEvents> getInstance() async {
    _instance ??= ClientEvents();
    return _instance!;
  }

  void publish(dynamic event) {
    _bus.fire(event);
  }

  Stream<T> subscribe<T>() {
    return _bus.on<T>();
  }

  // private:
  static ClientEvents? _instance;
  final _bus = EventBus(sync: true);
}
