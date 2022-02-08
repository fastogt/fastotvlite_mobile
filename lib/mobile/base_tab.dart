import 'package:fastotvlite/base/tabbar.dart';
import 'package:fastotvlite/bloc/base_bloc.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/events/ascending.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

abstract class IStreamBaseListPage<T extends IStream, U extends StatefulWidget> extends State<U>
    with TickerProviderStateMixin {
  late TabController tabController;

  BaseStreamBloc<T> get bloc;

  Map<String, List<T>> get channelsMap => bloc.streamsMap;

  Widget listBuilder(List<T> list);

  String noRecent();

  String noFavorite();

  @override
  void initState() {
    super.initState();
    _initTabController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<T>>>(
        initialData: bloc.streamsMap,
        stream: bloc.streamsMapUpdates,
        builder: (context, snapshot) {
          if (tabController.length != snapshot.data?.length) {
            _initTabController();
          }
          return Center(
              key: UniqueKey(),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                      children: <Widget>[_makeTabBar(), Expanded(child: _makeTabListPage())])));
        });
  }

  Widget _makeTabBar() {
    final categories = bloc.categories;
    final tabBar = TabBarEx(
        tabController, List<String>.generate(categories.length, (index) => categories[index]));
    return Row(children: <Widget>[
      Expanded(child: Material(elevation: 4, child: tabBar, color: Theme.of(context).primaryColor))
    ]);
  }

  Widget _makeTabListPage() {
    return TabBarView(controller: tabController, children: generateList());
  }

  void _initTabController() {
    final String currentCategory = bloc.category;
    int init;
    if (bloc.categories.contains(currentCategory)) {
      init = bloc.categories.indexOf(bloc.category);
    } else {
      init = bloc.categories.indexOf(TR_ALL);
    }
    tabController = TabController(vsync: this, length: channelsMap.length, initialIndex: init);
    tabController.addListener(() {
      bloc.setCategory(channelsMap.keys.toList()[tabController.index]);
    });
  }

  // public:
  Widget generateTab(String title) {
    if (title == TR_ALL || title == TR_RECENT || title == TR_FAVORITE) {
      return Tab(text: translate(context, title));
    }
    return Tab(text: AppLocalizations.toUtf8(title));
  }

  List<Widget> generateList() {
    final List<Widget> result = [];
    for (final category in channelsMap.keys) {
      if (category == TR_FAVORITE && channelsMap[TR_FAVORITE]!.isEmpty) {
        result.add(NonAvailableBuffer(
          icon: Icons.favorite_border,
          message: noFavorite(),
        ));
      } else if (category == TR_RECENT && channelsMap[TR_RECENT]!.isEmpty) {
        result.add(NonAvailableBuffer(
          icon: Icons.replay,
          message: noRecent(),
        ));
      } else {
        result.add(listBuilder(channelsMap[category]!));
      }
    }
    return result;
  }

  void addFavorite(T stream) => bloc.addFavorite(stream);

  void deleteFavorite(T stream) => bloc.deleteFavorite(stream);

  void handleFavorite(bool value, T stream) => bloc.handleFavorite(value, stream);

  void addRecent(T channel) => bloc.addRecent(channel);

  void sortRecent() => bloc.sortRecent();

  void edit(T stream, List<String> prevGroups) {
    bloc.edit(stream, prevGroups);
    bloc.updateMap();
  }

  void delete(T stream) {
    bloc.delete(stream);
    bloc.updateMap();
    if (bloc.map[TR_ALL]!.isEmpty) {
      final listEvents = locator<ClientEvents>();
      listEvents.publish(StreamsListEmptyEvent());
    }
  }
}
