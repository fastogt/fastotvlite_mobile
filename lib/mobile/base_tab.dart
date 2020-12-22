import 'package:fastotvlite/base/stream_parser.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/events/ascending.dart';
import 'package:fastotvlite/events/descending.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/no_channels.dart';
import 'package:flutter_common/localization/app_localizations.dart';

const TAB_BAR_HEIGHT = 46.0;

abstract class BaseListTab<T extends IStream> extends StatefulWidget {
  final Key key;
  final List<T> channels;

  BaseListTab(this.key, this.channels);
}

abstract class VideoAppState<T extends IStream> extends State<BaseListTab> with TickerProviderStateMixin {
  TabController tabController;
  Map<String, List<T>> channelsMap = {};
  bool tabsVisibility = true;

  String noRecent();

  String noFavorite();

  void onSearch(T stream);

  @override
  void initState() {
    super.initState();

    parseChannels();
    initTabController();

    final _search = locator<SearchEvents>();
    _search.subscribe<SearchEvent<T>>().listen((event) {
      onSearch(event.stream);
    });

    final events = locator<StreamListEvent>();
    events.subscribe<StreamsAddedEvent>().listen((_) {
      parseChannels();
      initTabController();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [
      Material(elevation: 4, child: CustomTabBar(_makeTabBar())),
      Expanded(child: TabBarView(controller: tabController, children: _generateList())),
    ];

    return Builder(builder: (BuildContext context) {
      return Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: columnChildren)));
    });
  }

  /// Splits channel list by groups
  void parseChannels() async {
    channelsMap = StreamsParser<T>(widget.channels).parseChannels();
  }

  /// TabBar

  void initTabController({int customValue}) async {
    tabController = new TabController(
        vsync: this,
        length: channelsMap.length,
        initialIndex: customValue ?? channelsMap[TR_RECENT].isNotEmpty ? 1 : 2);
  }

  Widget _makeTabBar() {
    final theme = Theme.of(context);
    return new TabBar(
        isScrollable: true,
        indicatorColor: theme.accentColor,
        labelColor: Theming.of(context).onCustomColor(theme.primaryColor),
        labelStyle: new TextStyle(fontSize: 16.0),
        indicatorSize: TabBarIndicatorSize.tab,
        controller: tabController,
        tabs: _generateTabs());
  }

  List<Widget> _generateTabs() {
    List<Widget> result = [];
    for (final category in channelsMap.keys) {
      result.add(_generateTab(category));
    }
    return result;
  }

  Widget _generateTab(String title) {
    if (title == TR_ALL || title == TR_RECENT || title == TR_FAVORITE) {
      return new Tab(text: AppLocalizations.of(context).translate(title));
    }
    return new Tab(text: AppLocalizations.toUtf8(title));
  }

  /// TabBarView
  List<Widget> _generateList() {
    List<Widget> result = [];
    for (final category in channelsMap.keys) {
      if (category == TR_FAVORITE && channelsMap[TR_FAVORITE].length == 0) {
        result.add(NonAvailableBuffer(
          icon: Icons.favorite_border,
          message: noFavorite(),
        ));
      } else if (category == TR_RECENT && channelsMap[TR_RECENT].length == 0) {
        result.add(NonAvailableBuffer(
          icon: Icons.replay,
          message: noRecent(),
        ));
      } else {
        result.add(listBuilder(channelsMap[category]));
      }
    }
    return result;
  }

  Widget listBuilder(List<T> list);

  String getCurrentGroup() {
    int count = 0;
    for (final category in channelsMap.keys) {
      if (count == tabController.index) {
        return category;
      }
    }
    return TR_ALL;
  }

  /// Favorite

  void addFavorite(T channel) {
    channelsMap[TR_FAVORITE].add(channel);
    setState(() {});
  }

  void deleteFavorite(T channel) {
    channelsMap[TR_FAVORITE].remove(channel);
    setState(() {});
  }

  void handleFavorite(bool value, T stream) {
    stream.setFavorite(value);
    stream.favorite() ? addFavorite(stream) : deleteFavorite(stream);
  }

  /// Recent

  void addRecent(T channel) {
    if (tabController.index != 1) {
      if (channelsMap[TR_RECENT].contains(channel)) {
        sortRecent();
      } else {
        channelsMap[TR_RECENT].insert(0, channel);
      }
      setState(() {});
    }
  }

  void sortRecent() {
    channelsMap[TR_RECENT].sort((b, a) => a.recentTime().compareTo(b.recentTime()));
  }

  /// Edit

  void handleStreamEdit() {
    if (widget.channels.isNotEmpty) {
      final startIndex = tabController.index;
      final currentGroup = channelsMap.keys.toList().elementAt(startIndex);
      parseChannels();
      initTabController();
      int index;
      final _groupList = channelsMap.keys.toList();
      if (_groupList.contains(currentGroup)) {
        index = _groupList.indexOf(currentGroup);
      } else {
        index = startIndex - 1;
      }
      tabController.animateTo(index, duration: Duration(microseconds: 1));
      setState(() {});
    } else {
      final listEvents = locator<StreamListEvent>();
      listEvents.publish(StreamsListEmptyEvent());
    }
  }

  void onTapped(List<T> channels, int position);

  void openChannel(List<T> channels, int position) {
    tabController.animateTo(0);
    onTapped(channels, position);
  }
}

class CustomTabBar extends StatefulWidget {
  final TabBar bar;

  CustomTabBar(this.bar);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  // Todo set proper color, when theme.type is dark or colored dark
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColor,
        height: TAB_BAR_HEIGHT,
        width: MediaQuery.of(context).size.width,
        child: Material(color: Theme.of(context).primaryColor, child: widget.bar));
  }
}
