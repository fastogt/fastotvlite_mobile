import 'package:fastotvlite/base/login/textfields.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

class SearchPage extends StatefulWidget {
  final List<IStream> streams;

  const SearchPage(this.streams);

  @override
  _SearchPageState createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  final TextFieldNode _textFieldNode =
      TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final TextEditingController _controller = TextEditingController(text: '');
  List<IStream> _streams = [];

  @override
  void initState() {
    super.initState();
    widget.streams.forEach((s) => _streams.add(s));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theming.of(context).theme.scaffoldBackgroundColor,
        appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theming.of(context).theme.scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: Theming.of(context).onBrightness()),
            title: FractionallySizedBox(child: field(), widthFactor: 0.5),
            leading: IconButton(
                autofocus: true,
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _exit(null);
                })),
        body: _body());
  }

  Widget field() {
    return LoginTextField(
        mainFocus: _textFieldNode.main,
        textFocus: _textFieldNode.text,
        controller: _controller,
        hintText: 'Enter name',
        obscureText: false,
        onFieldSubmit: (text) {
          _search(text);
        });
  }

  Widget _body() {
    if (_streams.isEmpty) {
      return const Center(child: NonAvailableBuffer(icon: Icons.search, message: 'Nothing found'));
    }
    return Center(
        child: FractionallySizedBox(
            widthFactor: 0.4,
            child: ListView.builder(
                itemCount: _streams.length,
                itemBuilder: (BuildContext context, int index) {
                  return tile(_streams[index]);
                })));
  }

  Widget tile(IStream stream) {
    return ListTile(
        key: UniqueKey(),
        onTap: () {
          _exit(stream);
        },
        leading: PreviewIcon.live(stream.icon(), height: 40, width: 40),
        title: Text(AppLocalizations.toUtf8(stream.displayName()),
            maxLines: 2, overflow: TextOverflow.ellipsis));
  }

  void _search(String term) {
    final List<IStream> result = [];
    widget.streams.forEach((stream) {
      final _term = term.toLowerCase();
      if (stream.displayName().toLowerCase().contains(_term)) {
        result.add(stream);
      }
    });
    setState(() {
      _streams = result;
    });
  }

  void _exit(IStream? stream) {
    Navigator.of(context).pop(stream);
  }
}
