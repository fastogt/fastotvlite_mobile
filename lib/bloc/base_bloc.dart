import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseStreamBloc<T extends IStream> {
  Map<String, List<T>> map = {TR_ALL: []};
  String _currentcategory = TR_ALL;
  final BehaviorSubject<Map<String, List<T>>> streamsMapUpd =
      BehaviorSubject<Map<String, List<T>>>();
  final NavigatorState navigator;

  BaseStreamBloc(List<T> streams, this.navigator) {
    final _search = locator<SearchEvents>();
    _search.subscribe<StreamSearchEvent<T>>().listen((stream) => onSearch(stream.stream));
    map = parseMap(streams);
    _currentcategory = map[TR_RECENT]!.isNotEmpty ? TR_RECENT : TR_ALL;
    streamsMapUpd.add(map);
  }

  Map<String, List<T>> parseMap(List<T> streams);

  Map<String, List<T>> get streamsMap => map;

  Stream<Map<String, List<T>>> get streamsMapUpdates => streamsMapUpd.stream;

  String get category => _currentcategory;

  List<String> get categories => map.keys.toList();

  void updateMap() {
    streamsMapUpd.add(map);
    saveStreams();
  }

  void setCategory(String category) {
    _currentcategory = category;
  }

  void dispose() {
    streamsMapUpd.close();
  }

  void onSearch(T stream);

  void addFavorite(T stream) {
    map[TR_FAVORITE]!.add(stream);
  }

  void deleteFavorite(T stream) {
    map[TR_FAVORITE]!.remove(stream);
  }

  void handleFavorite(bool value, T stream) {
    stream.setFavorite(value);
    stream.favorite() ? addFavorite(stream) : deleteFavorite(stream);
    updateMap();
  }

  void addRecent(T stream) {
    if (map[TR_RECENT]!.contains(stream)) {
      sortRecent();
    } else {
      map[TR_RECENT]!.insert(0, stream);
    }
  }

  void sortRecent() {
    map[TR_RECENT]!.sort((b, a) => a.recentTime().compareTo(b.recentTime()));
  }

  void sortGroup(String group) {
    map[group]!.sort((a, b) => a.displayName().compareTo(b.displayName()));
  }

  void addStream(T stream) {
    map[TR_ALL]!.add(stream);
    _addToGroup(stream);
  }

  void edit(T stream, List<String> previousGroups) {
    for (final String group in [TR_FAVORITE, TR_RECENT, TR_ALL]) {
      _updateStreamInGroup(stream, group);
    }
    for (final String group in stream.groups()) {
      if (previousGroups.contains(group)) {
        _updateStreamInGroup(stream, group);
      } else {
        _addToGroup(stream);
      }
      previousGroups.remove(group);
    }
    previousGroups.forEach((oldGroup) {
      _removeFromGroup(oldGroup, stream);
    });
    previousGroups.clear();
  }

  void delete(T stream) {
    map[TR_FAVORITE]!.remove(stream);
    map[TR_RECENT]!.remove(stream);
    map[TR_ALL]!.remove(stream);
    stream.groups().forEach((group) {
      _removeFromGroup(group, stream);
    });
  }

  void saveStreams();

  void _addToGroup(T stream) {
    for (final String group in stream.groups()) {
      if (map[group] != null) {
        map[group]!.add(stream);
      } else {
        map[group] = [stream];
      }
    }
  }

  void _updateStreamInGroup(T stream, String group) {
    final List<T> streams = map[group]!;
    for (int i = 0; i < streams.length; i++) {
      if (streams[i].id() == stream.id()) {
        streams[i] = stream;
        break;
      }
    }
  }

  void _removeFromGroup(String group, T stream) {
    if (map[group]!.length == 1) {
      map.remove(group);
    } else {
      map[group]!.remove(stream);
    }
  }
}
