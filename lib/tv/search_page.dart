import 'package:fastotvlite/base/login/textfields.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/base/controls/no_channels.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/tv/key_code.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

class SearchPage extends StatefulWidget {
  final List<IStream> streams;

  SearchPage(this.streams);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<IStream> _streams = [];

  @override
  void initState() {
    super.initState();
    _streams.addAll(widget.streams);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final appBarTextColor = Theming.of(context).onCustomColor(primaryColor);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: primaryColor,
            appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                iconTheme: IconThemeData(color: appBarTextColor),
                title: FractionallySizedBox(child: _SearchField(_search), widthFactor: 0.5),
                leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => _exit(null))),
            body: _body()));
  }

  Widget _body() {
    if (_streams.isEmpty) {
      return Center(child: NonAvailableBuffer(icon: Icons.search, message: 'Nothing found'));
    }
    return Center(
        child: FractionallySizedBox(
            widthFactor: 0.4,
            child: Container(
                child: ListView.builder(
                    itemCount: _streams.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _Tile(channel: _streams[index], onChannel: _exit)))));
  }

  void _search(String term) {
    _streams.clear();
    widget.streams.forEach((stream) {
      if (stream.displayName().contains(term)) {
        _streams.add(stream);
      }
    });
    setState(() {});
  }

  void _exit(IStream stream) async {
    Navigator.of(context).pop(stream);
  }
}

class _SearchField extends StatefulWidget {
  final void Function(String) onEnter;

  _SearchField(this.onEnter);

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  TextFieldNode _textFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));

  TextEditingController _controller = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _textFieldNode.main.addListener(_updateField);
  }

  @override
  Widget build(BuildContext context) {
    return LoginTextField(
        mainFocus: _textFieldNode.main,
        textFocus: _textFieldNode.text,
        textEditingController: _controller,
        hintText: 'Enter name',
        obscureText: false,
        validate: true,
        onKey: _nodeAction,
        onFieldChanged: () {},
        onFieldSubmit: () => widget.onEnter(_controller.text));
  }

  void _updateField() {
    setState(() {});
  }

  void _onEnter(FocusNode node) {
    if (node == _textFieldNode.text) {
      FocusScope.of(context).requestFocus(_textFieldNode.main);
      widget.onEnter(_controller.text);
    } else {
      FocusScope.of(context).requestFocus(_textFieldNode.text);
    }
  }

  bool _nodeAction(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          _onEnter(node);
          break;
        case KEY_LEFT:
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          break;
        case KEY_RIGHT:
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
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
    }
    return node.hasFocus;
  }
}

class _Tile extends StatefulWidget {
  final IStream channel;
  final void Function(IStream) onChannel;

  _Tile({@required this.channel, @required this.onChannel});

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<_Tile> {
  static const Size CHANNEL_AVATAR_SIZE = Size(40.0, 40.0);

  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        key: UniqueKey(),
        focusNode: _node,
        onKey: _onChannel,
        child: Stack(children: <Widget>[Positioned.fill(child: _background()), _tile()]));
  }

  // private:
  Widget _background() {
    return Container(color: _backgroundColor());
  }

  Widget _tile() {
    return ListTile(
        leading: _channelAvatar(widget.channel),
        title:
            Text(AppLocalizations.toUtf8(widget.channel.displayName()), maxLines: 2, overflow: TextOverflow.ellipsis));
  }

  Widget _channelAvatar(IStream channel) {
    return PreviewIcon.live(channel.icon(), height: CHANNEL_AVATAR_SIZE.height, width: CHANNEL_AVATAR_SIZE.width);
  }

  Color _backgroundColor() {
    if (!_node.hasFocus) {
      return Colors.transparent;
    }
    return Theme.of(context).focusColor;
  }

  void _onFocusChange() {
    setState(() {});
  }

  bool _onChannel(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      if (node.hasFocus || node.hasPrimaryFocus) {
        RawKeyDownEvent rawKeyDownEvent = event;
        RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
        switch (rawKeyEventDataAndroid.keyCode) {
          case KEY_LEFT:
            FocusScope.of(context).focusInDirection(TraversalDirection.left);
            break;

          case KEY_UP:
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
            break;

          case KEY_DOWN:
            FocusScope.of(context).focusInDirection(TraversalDirection.down);
            break;

          case ENTER:
          case KEY_CENTER:
            widget.onChannel(widget.channel);
            break;

          default:
            break;
        }
      }
    }
    return node.hasFocus;
  }
}
