import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/tv/add_streams/tv_edit_channel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class AbstractLiveEditPage extends StatefulWidget {
  final LiveStream stream;

  AbstractLiveEditPage(this.stream);
}

abstract class AbstractLiveEditPageState extends EditStreamPageTV<AbstractLiveEditPage> {
  static const int DEFAULT_IARC = 18;

  String appBarTitle() => 'Edit channel';

  LiveStream stream() => widget.stream;

  @override
  Widget deleteButton() => SizedBox();

  @override
  void initState() {
    super.initState();
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
      PreviewIcon.live(iconController.text),
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

class LiveAddPageTV extends AbstractLiveEditPage {
  LiveAddPageTV(stream) : super(stream);

  @override
  _LiveAddPageTVState createState() => _LiveAddPageTVState();
}

class _LiveAddPageTVState extends AbstractLiveEditPageState {
  @override
  void exitAndResetChanges() => Navigator.of(context).pop();
}

class LiveEditPageTV extends AbstractLiveEditPage {
  LiveEditPageTV(stream) : super(stream);

  @override
  _LiveEditPageTVState createState() => _LiveEditPageTVState();
}

class _LiveEditPageTVState extends AbstractLiveEditPageState {}
