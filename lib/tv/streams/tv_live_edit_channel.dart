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
