import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/tv/add_streams/tv_edit_channel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class AbstractLiveEditPage extends StatefulWidget {
  final LiveStream stream;

  const AbstractLiveEditPage(this.stream);
}

abstract class AbstractLiveEditPageState extends EditStreamPageTV<AbstractLiveEditPage> {
  static const int DEFAULT_IARC = 18;

  @override
  String appBarTitle() => 'Edit channel';

  @override
  LiveStream stream() => widget.stream;

  @override
  Widget deleteButton() => const SizedBox();

  @override
  Widget editingPage() {
    final size = MediaQuery
        .of(context)
        .size;
    return Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
          PreviewIcon.live(iconController.text),
          const SizedBox(width: 16),
          SizedBox(
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
  const LiveAddPageTV(stream) : super(stream);

  @override
  _LiveAddPageTVState createState() => _LiveAddPageTVState();
}

class _LiveAddPageTVState extends AbstractLiveEditPageState {}

class LiveEditPageTV extends AbstractLiveEditPage {
  const LiveEditPageTV(stream) : super(stream);

  @override
  _LiveEditPageTVState createState() => _LiveEditPageTVState();
}

class _LiveEditPageTVState extends AbstractLiveEditPageState {}
