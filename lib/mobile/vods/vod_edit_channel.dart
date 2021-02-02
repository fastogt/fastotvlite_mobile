import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/add_streams/edit_channel_page.dart';
import 'package:flutter/material.dart';

abstract class _AbstractVodEditPage extends EditStreamPage<VodStream> {
  _AbstractVodEditPage(VodStream stream) : super(stream);
}

abstract class _AbstractVodEditPageState extends EditStreamPageState<VodStream> {}

class VodAddPage extends _AbstractVodEditPage {
  VodAddPage(stream) : super(stream);

  @override
  _VodAddPageState createState() => _VodAddPageState();
}

class _VodAddPageState extends _AbstractVodEditPageState {
  @override
  String get appBarTitle => TR_ADD_VOD;

  @override
  Widget deleteButton() => SizedBox();
}

class VodEditPage extends _AbstractVodEditPage {
  VodEditPage(stream) : super(stream);

  @override
  _VodEditPageState createState() => _VodEditPageState();
}

class _VodEditPageState extends _AbstractVodEditPageState {
  @override
  String get appBarTitle => TR_EDIT_STREAM;
}
