import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class TabBarEx extends StatefulWidget {
  static const TABBAR_FONT_SIZE_TV = 20.0;

  final TabController controller;
  final List<String> items;

  const TabBarEx(this.controller, this.items);

  @override
  _TabBarExState createState() {
    return _TabBarExState();
  }
}

class _TabBarExState extends State<TabBarEx> {
  bool _hasTouch;

  bool isActive(int index) => widget.controller.index == index;

  List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    final device = locator<RuntimeDevice>();
    _hasTouch = device.hasTouch;
    if (!_hasTouch) {
      widget.controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tabs.isEmpty) _tabs = List<Widget>.generate(widget.controller.length, _generateTab);
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: _indicatorColor,
        labelColor: _labelColor,
        controller: widget.controller,
        isScrollable: true,
        tabs: _tabs);
  }

  Widget _generateTab(int index) {
    if (_hasTouch) {
      return Tab(text: _title(widget.items[index]));
    } else {
      return Tab(child: Text(_title(widget.items[index]), style: _tvStyle(index)));
    }
  }

  Color get _labelColor {
    if (_hasTouch) {
      return Theming.of(context).onPrimary();
    } else {
      return Theming.of(context).onBrightness();
    }
  }

  Color get _indicatorColor => Theme.of(context).colorScheme.secondary;

  String _title(String title) {
    if (title == TR_ALL ||
        title == TR_RECENT ||
        title == TR_FAVORITE ||
        title == TR_LIVE_TV ||
        title == TR_VODS) {
      return AppLocalizations.of(context).translate(title);
    }
    return AppLocalizations.toUtf8(title);
  }

  TextStyle _tvStyle(int index) {
    if (isActive(index)) {
      return TextStyle(
          fontSize: TabBarEx.TABBAR_FONT_SIZE_TV,
          color: Theming.of(context).onBrightness(),
          fontWeight: FontWeight.bold);
    } else {
      return TextStyle(
          fontSize: TabBarEx.TABBAR_FONT_SIZE_TV,
          color: Theming.of(context).onBrightness(light: Colors.black87, dark: Colors.white70),
          fontWeight: FontWeight.normal);
    }
  }
}
