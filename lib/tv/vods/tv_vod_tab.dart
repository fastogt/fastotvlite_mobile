import 'package:fastotvlite/base/stream_parser.dart';
import 'package:fastotvlite/base/vods/constants.dart';
import 'package:fastotvlite/base/vods/vod_card_favorite_pos.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/vods/tv_vod_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/base/controls/no_channels.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/tv/key_code.dart';
import 'package:flutter_fastotv_common/base/vods/vod_card.dart';

class TVVodPage extends StatefulWidget {
  final Key key;
  final List<VodStream> channels;

  TVVodPage(this.channels) : key = GlobalKey();

  @override
  _TVVodPageState createState() => _TVVodPageState();
}

class _TVVodPageState extends State<TVVodPage> with TickerProviderStateMixin {
  static const BORDER_WIDTH = 6.0;

  static const TABBAR_FONT_SIZE = 24.0;

  Map<String, List<VodStream>> channelsMap = {};

  TabController _tabController;
  int currentCategory = 2;

  void _initTabController() async {
    _tabController = new TabController(vsync: this, length: channelsMap.keys.length, initialIndex: 2);
  }

  @override
  void initState() {
    super.initState();
    channelsMap = StreamsParser<VodStream>(widget.channels).parseChannels();
    _initTabController();
    final _search = locator<SearchEvents>();
    _search.subscribe<SearchEvent<VodStream>>().listen((event) => _onSearch(event.stream));
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);

    return Container(
        height: query.size.height,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          _tabBar(),
          Expanded(child: TabBarView(controller: _tabController, children: _generateList()))
        ]));
  }

  /// TabBar

  Widget _tabBar() {
    final active =
        TextStyle(fontSize: TABBAR_FONT_SIZE, color: Theming.of(context).onBrightness(), fontWeight: FontWeight.bold);
    final inactive = TextStyle(
        fontSize: TABBAR_FONT_SIZE,
        color: Theming.of(context).onBrightness(light: Colors.black87, dark: Colors.white70),
        fontWeight: FontWeight.normal);

    bool isActive(int index) {
      return _tabController.index == index;
    }

    String _title(String title) {
      if (title == TR_ALL || title == TR_RECENT || title == TR_FAVORITE) {
        return AppLocalizations.of(context).translate(title);
      }
      return AppLocalizations.toUtf8(title);
    }

    List<Widget> tabsGenerator() {
      return List.generate(channelsMap.keys.length, (int index) {
        return Tab(
            child: Container(
                child: Text(_title(channelsMap.keys.toList()[index]), style: isActive(index) ? active : inactive)));
      });
    }

    Widget tabs = TabBar(
        labelStyle: new TextStyle(fontSize: 16.0),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Theme.of(context).accentColor,
        controller: _tabController,
        isScrollable: true,
        tabs: tabsGenerator());

    return tabs;
  }

  List<Widget> _generateList() {
    List<Widget> result = [];
    for (final category in channelsMap.keys) {
      if (category == TR_FAVORITE && channelsMap[TR_FAVORITE].length == 0) {
        result.add(NonAvailableBuffer(
          icon: Icons.favorite_border,
          message: 'You dont\' have any favorite channels',
        ));
      } else if (category == TR_RECENT && channelsMap[TR_RECENT].length == 0) {
        result.add(NonAvailableBuffer(
          icon: Icons.replay,
          message: 'You dont\' have any recently viewed channels',
        ));
      } else {
        result.add(_cardList(category));
      }
    }
    return result;
  }

  Widget _cardList(String category) {
    final _list = channelsMap[category];
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: CARD_WIDTH_TV + 2 * EDGE_INSETS,
                    crossAxisSpacing: EDGE_INSETS,
                    mainAxisSpacing: EDGE_INSETS,
                    childAspectRatio: 2 / 3),
                itemCount: _list.length,
                itemBuilder: (BuildContext context, int index) {
                  final node = _list[index];
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: EDGE_INSETS, vertical: EDGE_INSETS * 1.5),
                      child: Center(child: _CardWrap(node, _onCard, CARD_WIDTH_TV, BORDER_WIDTH)));
                })));
  }

  void _onCardTap(VodStream channel) async {
    final previousFavorite = channel.favorite();
    await Navigator.push(context, MaterialPageRoute(builder: (context) => TvVodDescription(channel: channel)));
    if (previousFavorite != channel.favorite()) handleFavorite(channel);
    addRecent(channel);
    if (mounted) {
      setState(() {});
    }
  }

  bool _onCard(RawKeyEvent event, VodStream channel) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          _onCardTap(channel);
          break;

        case KEY_LEFT:
          if (FocusScope.of(context).focusedChild.offset.dx > CARD_WIDTH_TV) {
            FocusScope.of(context).focusInDirection(TraversalDirection.left);
          } else {
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
            while (
                MediaQuery.of(context).size.width - FocusScope.of(context).focusedChild.offset.dx > CARD_WIDTH_TV * 2) {
              FocusScope.of(context).focusInDirection(TraversalDirection.right);
            }
          }
          break;

        case KEY_RIGHT:
          if (MediaQuery.of(context).size.width - FocusScope.of(context).focusedChild.offset.dx > CARD_WIDTH_TV * 2) {
            FocusScope.of(context).focusInDirection(TraversalDirection.right);
          } else {
            while (FocusScope.of(context).focusedChild.offset.dx > CARD_WIDTH_TV) {
              FocusScope.of(context).focusInDirection(TraversalDirection.left);
            }
            FocusScope.of(context).focusInDirection(TraversalDirection.down);
          }
          break;

        case KEY_UP:
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          break;

        case KEY_DOWN:
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          break;

        default:
          break;
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  void handleFavorite(VodStream channel) {
    void addFavorite(VodStream channel) {
      channelsMap[TR_FAVORITE].add(channel);
    }

    void deleteFavorite(VodStream channel) {
      channelsMap[TR_FAVORITE].remove(channel);
    }

    channel.favorite() ? addFavorite(channel) : deleteFavorite(channel);
  }

  void addRecent(VodStream channel) {
    if (channelsMap[TR_RECENT].contains(channel)) {
      channelsMap[TR_RECENT].sort((b, a) => a.recentTime().compareTo(b.recentTime()));
    } else {
      channelsMap[TR_RECENT].insert(0, channel);
    }
  }

  void _onSearch(VodStream stream) {
    for (int i = 0; i < channelsMap[TR_ALL].length; i++) {
      final s = channelsMap[TR_ALL][i];
      if (s.displayName() == stream.displayName()) {
        currentCategory = 2;
        _onCardTap(s);
        break;
      }
    }
  }
}

class _CardWrap extends StatefulWidget {
  final VodStream channel;
  final bool Function(RawKeyEvent event, VodStream channel) onKey;
  final double cardWidth;
  final double borderWidth;

  _CardWrap(this.channel, this.onKey, this.cardWidth, this.borderWidth);

  @override
  _CardWrapState createState() => _CardWrapState();
}

class _CardWrapState extends State<_CardWrap> {
  FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: _node,
        onKey: (node, event) => widget.onKey(event, widget.channel),
        child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: _node.hasFocus ? Colors.amber : Colors.transparent, width: widget.borderWidth)),
            child: Stack(children: <Widget>[
              VodCard(
                  iconLink: widget.channel.icon(),
                  duration: widget.channel.duration(),
                  interruptTime: widget.channel.interruptTime(),
                  width: widget.cardWidth),
              VodFavoriteButton(
                  child: Icon(widget.channel.favorite() ? Icons.star : Icons.star_border,
                      color: widget.channel.favorite()
                          ? Theming.of(context).theme.accentColor
                          : Theming.of(context).onPrimary()))
            ])));
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
