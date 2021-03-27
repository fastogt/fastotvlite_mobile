import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/add_streams/edit_channel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

abstract class _AbstractLiveEditPage extends EditStreamPage<LiveStream> {
  const _AbstractLiveEditPage(LiveStream stream) : super(stream);
}

abstract class _AbstractLiveEditPageState extends EditStreamPageState<LiveStream> {
  TextEditingController idController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.stream.epgUrl());
  }

  @override
  List<Widget> content() {
    return <Widget>[
      ...super.content(),
      textField(translate(context, TR_EPG_PROVIDER), idController)
    ];
  }

  @override
  void onSave() {
    super.onSave();
    widget.stream.setEpgUrl(idController.text);
  }
}

class LiveAddPage extends _AbstractLiveEditPage {
  const LiveAddPage(stream) : super(stream);

  @override
  _LiveAddPageState createState() => _LiveAddPageState();
}

class _LiveAddPageState extends _AbstractLiveEditPageState {
  @override
  String get appBarTitle => TR_ADD_CHANNEL;

  @override
  Widget deleteButton() => const SizedBox();
}

class LiveEditPage extends _AbstractLiveEditPage {
  const LiveEditPage(stream) : super(stream);

  @override
  _LiveEditPageState createState() => _LiveEditPageState();
}

class _LiveEditPageState extends _AbstractLiveEditPageState {
  @override
  String get appBarTitle => TR_EDIT_STREAM;
}
