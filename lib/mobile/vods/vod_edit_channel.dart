import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/add_streams/edit_channel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class _AbstractVodEditPage extends StatefulWidget {
  final VodStream stream;

  _AbstractVodEditPage(this.stream);
}

abstract class _AbstractVodEditPageState extends EditStreamPageState<_AbstractVodEditPage> {
  static const int DEFAULT_IARC = 18;

  TextEditingController descriptionController;
  TextEditingController nameController;
  TextEditingController iconController;
  TextEditingController videoLinkController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: AppLocalizations.toUtf8(widget.stream.displayName()));
    iconController = TextEditingController(text: widget.stream.icon());
    videoLinkController = TextEditingController(text: widget.stream.primaryUrl());
    validator = videoLinkController.text.isNotEmpty;
  }

  String appBarTitle() => translate(context, TR_EDIT_STREAM);

  VodStream stream() => widget.stream;

  void onSave() {
    widget.stream.setDisplayName(nameController.text);
    widget.stream.setPrimaryUrl(videoLinkController.text);
    widget.stream.setIcon(iconController.text);
    widget.stream.setIarc(int.tryParse(iarcController.text) ?? DEFAULT_IARC);
    widget.stream.setGroups(groups);
  }

  Widget editingPage() {
    return Column(children: <Widget>[
      Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.shortestSide, maxHeight: MediaQuery.of(context).size.shortestSide),
          child: PreviewIcon.vod(iconController.text)),
      textField(translate(context, TR_EDIT_TITLE), nameController),
      groupsField(),
      textField(translate(context, TR_EDIT_VIDEO_LINK), videoLinkController,
          onSubmitted: () => setState(() => validator = videoLinkController.text.isNotEmpty)),
      textField(translate(context, TR_EDIT_ICON), iconController, onSubmitted: () => setState(() {})),
      textField('IARC', iarcController)
    ]);
  }
}

class VodAddPage extends _AbstractVodEditPage {
  VodAddPage(stream) : super(stream);

  @override
  _VodAddPageState createState() => _VodAddPageState();
}

class _VodAddPageState extends _AbstractVodEditPageState {
  @override
  String appBarTitle() => translate(context, TR_ADD_VOD);

  @override
  Widget deleteButton() => SizedBox();
}

class VodEditPage extends _AbstractVodEditPage {
  VodEditPage(stream) : super(stream);

  @override
  _VodEditPageState createState() => _VodEditPageState();
}

class _VodEditPageState extends _AbstractVodEditPageState {}
