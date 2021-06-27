import 'package:fastotvlite/base/add_streams/m3u_file_picker.dart';
import 'package:fastotvlite/base/add_streams/m3u_to_channels.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/add_streams/select_stream_page.dart';
import 'package:fastotvlite/mobile/streams/live_edit_channel.dart';
import 'package:fastotvlite/mobile/vods/vod_edit_channel.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/add_streams/tv_select_stream_page.dart';
import 'package:fastotvlite/tv/streams/tv_live_edit_channel.dart';
import 'package:fastotvlite/tv/vods/tv_vod_edit_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

enum PickStreamFrom { PLAYLIST, SINGLE_STREAM }

class LoadingPlaylistNotification extends Notification {
  final bool isLoading;

  const LoadingPlaylistNotification(this.isLoading);
}

abstract class BaseFilePickerDialog extends StatefulWidget {
  final PickStreamFrom source;

  const BaseFilePickerDialog(this.source);
}

abstract class BaseFilePickerDialogState extends State<BaseFilePickerDialog> {
  String m3uText;
  StreamType _streamType;
  bool _inputLink = false;
  bool loading = false;
  bool validator = true;
  bool hasTouch = true;
  String hintText = TR_INPUT_LINK;
  TextEditingController controller = TextEditingController();

  Widget textField();

  @override
  void initState() {
    super.initState();
    final device = locator<RuntimeDevice>();
    hasTouch = device.hasTouch;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Row(children: <Widget>[
          _backButton(),
          Text(translate(_inputLink ? TR_INPUT_LINK : TR_ADD_STREAMS)),
          const Spacer(),
          _exitButton()
        ]),
        titlePadding: EdgeInsets.symmetric(
            vertical: !hasTouch || _inputLink ? 12 : 24, horizontal: _inputLink ? 8 : 24),
        contentPadding: EdgeInsets.symmetric(horizontal: _inputLink ? 24 : 0),
        content: loading
            ? _loadingWidget()
            : SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                const Divider(height: 0),
                if (_inputLink) textField() else _tiles(),
                const Divider(height: 0),
                _fileButtonsRow(),
                const Divider(height: 0)
              ])));
  }

  Widget _loadingWidget() {
    final color = Theme.of(context).colorScheme.secondary;
    return SizedBox(
        height: 64,
        width: 64,
        child: Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(color))));
  }

  Widget _button(String text, void Function() onPressed) {
    final activeColor = hasTouch ? Theme.of(context).colorScheme.secondary : null;
    final disabledColor = Theming.of(context).onBrightness().withOpacity(0.5);
    return ElevatedButton(
        style: ElevatedButton.styleFrom(primary: activeColor),
        child: Text(text,
            style: hasTouch
                ? TextStyle(
                    color: backgroundColorBrightness(!validator ? disabledColor : activeColor))
                : null),
        onPressed: onPressed);
  }

  Widget _backButton() {
    if (!_inputLink) {
      return const SizedBox();
    }
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => setState(() => _inputLink = false),
        padding: const EdgeInsets.all(0));
  }

  Widget _exitButton() {
    if (hasTouch) {
      return const SizedBox();
    }
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.of(context).pop(),
      padding: const EdgeInsets.all(0),
    );
  }

  Widget _tiles() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[_typeTile(StreamType.Live), _typeTile(StreamType.Vod)]);
  }

  Widget _typeTile(StreamType value) {
    return ListTile(
        title: Text(translate(value == StreamType.Live ? TR_LIVE_TV : TR_VODS)),
        onTap: hasTouch ? () => _onChanged(value) : null,
        leading: Radio(
            autofocus: true,
            groupValue: _streamType,
            value: value,
            onChanged: (StreamType value) => _onChanged(value)));
  }

  Widget _fileButtonsRow() {
    if (widget.source == PickStreamFrom.SINGLE_STREAM || _streamType == null) {
      return const SizedBox(height: 0);
    }

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: _inputLink ? 0 : 24, vertical: 16),
        child: _inputLink
            ? _button(translate(TR_LOAD), _streamType == null ? null : () => _loadFromLink())
            : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                _button(translate(TR_ADD_FILE), _streamType == null ? null : () => _onFile()),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(translate(TR_ADD_OR))),
                _button(translate(TR_ADD_LINK),
                    _streamType == null ? null : () => setState(() => _inputLink = true))
              ]));
  }

  // common
  void _onChanged(StreamType value) {
    setState(() => _streamType = value);
    if (widget.source == PickStreamFrom.SINGLE_STREAM) {
      _addStream();
    }
  }

  void _setLoading(bool value) async {
    setState(() => loading = value);
    LoadingPlaylistNotification(value).dispatch(context);
    if (!value) {
      AddStreamResponse output;
      if (m3uText != null) {
        if (m3uText.isNotEmpty) {
          output = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => hasTouch
                  ? ChannelsPreviewPage(m3uText, _streamType)
                  : SelectStreamTV(m3uText, _streamType)));
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.of(context).pop(output));
    }
  }

  void _addStream() async {
    AddStreamResponse _result;
    if (_streamType == StreamType.Live) {
      final LiveStream _response = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              hasTouch ? LiveAddPage(LiveStream.empty()) : LiveAddPageTV(LiveStream.empty())));
      if (_response != null) {
        _result = AddStreamResponse(StreamType.Live, channels: [_response]);
      }
    } else {
      final VodStream _response = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              hasTouch ? VodAddPage(VodStream.empty()) : VodAddPageTV(VodStream.empty())));
      if (_response != null) {
        _result = AddStreamResponse(StreamType.Vod, vods: [_response]);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.of(context).pop(_result));
  }

  // link
  void validateLink() {
    setState(() => validator = controller.text.isNotEmpty);
  }

  void _loadFromLink() async {
    validateLink();
    if (validator) {
      _setLoading(true);
      m3uText = await StreamFilePicker().link(controller.text);
      _setLoading(false);
    }
  }

  // file
  void _onFile() {
    if (_inputLink) {
      setState(() => _inputLink = false);
    }
    _pickFromFile();
  }

  void _pickFromFile() async {
    _setLoading(true);
    m3uText = await StreamFilePicker().file();
    _setLoading(false);
  }

  String translate(String key) => AppLocalizations.of(context).translate(key);
}
