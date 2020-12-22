import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/tv/add_streams/tv_edit_channel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class AbstractVodEditPage extends StatefulWidget {
  final VodStream stream;

  AbstractVodEditPage(this.stream);
}

abstract class AbstractVodEditPageState extends EditStreamPageTV<AbstractVodEditPage> {
  static const int DEFAULT_IARC = 18;

  String appBarTitle() => 'Edit channel';

  VodStream stream() => widget.stream;

  @override
  void initState() {
    super.initState();
    final groups = stream().groups();
    iarcController = TextEditingController(text: widget.stream.iarc().toString());
    nameController = TextEditingController(text: AppLocalizations.toUtf8(widget.stream.displayName()));
    iconController = TextEditingController(text: widget.stream.icon());
    videoLinkController = TextEditingController(text: widget.stream.primaryUrl());
    validator = videoLinkController.text.isNotEmpty;
  }

  Widget editingPage() {
    final size = MediaQuery.of(context).size;
    return Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
      PreviewIcon.vod(iconController.text),
      SizedBox(width: 16),
      Container(
          width: size.width / 2,
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            textField('Title', nameFieldNode, nameController),
            textField('Video link', urlFieldNode, videoLinkController),
            textField('Icon', iconFieldNode, iconController),
            textField('IARC', iarcFieldNode, iarcController)
          ])))
    ]));
  }

  void enterAction(FocusNode node) {
    if (node == nameFieldNode.main) {
      setFocus(nameFieldNode.text);
    } else if (node == urlFieldNode.main) {
      setFocus(urlFieldNode.text);
    } else if (node == iconFieldNode.main) {
      setFocus(iconFieldNode.text);
    } else if (node == iarcFieldNode.main) {
      setFocus(iarcFieldNode.text);
    } else if (node == backButtonNode) {
      exitAndResetChanges();
    } else if (node == saveButtonNode) {
      exitAndSaveChanges();
    }
  }

  void onSave() {
    widget.stream.setDisplayName(nameController.text);
    widget.stream.setPrimaryUrl(videoLinkController.text);
    widget.stream.setIcon(iconController.text);
    widget.stream.setIarc(int.tryParse(iarcController.text) ?? DEFAULT_IARC);
  }
}

class VodAddPageTV extends AbstractVodEditPage {
  VodAddPageTV(stream) : super(stream);

  @override
  _VodAddPageTVState createState() => _VodAddPageTVState();
}

class _VodAddPageTVState extends AbstractVodEditPageState {
  @override
  Widget deleteButton() => SizedBox();

  @override
  void exitAndResetChanges() => Navigator.of(context).pop();
}

class VodEditPageTV extends AbstractVodEditPage {
  VodEditPageTV(stream) : super(stream);

  @override
  _VodEditPageTVState createState() => _VodEditPageTVState();
}

class _VodEditPageTVState extends AbstractVodEditPageState {}
