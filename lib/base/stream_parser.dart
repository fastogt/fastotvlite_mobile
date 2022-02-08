import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/localization/translations.dart';

class StreamsParser<T extends IStream> {
  StreamsParser(this._channels);

  final List<T> _channels;
  final Map<String, List<T>> _channelsMap = {};

  Map<String, List<T>> parseChannels() {
    _channelsMap[TR_FAVORITE] = [];
    _channelsMap[TR_RECENT] = [];
    _channels.forEach((element) {
      _savePushFavorite(element);
      _savePushRecent(element);
      _savePushChannel(TR_ALL, element);
      final List<String> temp = element.groups();
      temp.toSet().forEach((singleGroup) => _savePushChannel(singleGroup, element));
    });
    _channelsMap[TR_RECENT]!.sort((b, a) => a.recentTime().compareTo(b.recentTime()));
    return _channelsMap;
  }

  // private:
  void _savePushChannel(String category, T element) {
    if (category.isEmpty) {
      return;
    }

    if (!_channelsMap.containsKey(category)) {
      _channelsMap[category] = [];
    }
    _channelsMap[category]!.add(element);
  }

  void _savePushFavorite(T element) {
    if (element.favorite()) {
      _channelsMap[TR_FAVORITE]!.add(element);
    }
  }

  void _savePushRecent(T element) {
    if (element.recentTime() > 0) {
      _channelsMap[TR_RECENT]!.insert(0, element);
    }
  }
}
