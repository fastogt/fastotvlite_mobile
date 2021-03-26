import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/tv/add_streams/tv_edit_channel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class AbstractVodEditPage extends StatefulWidget {
  final VodStream stream;

  AbstractVodEditPage(this.stream);
}

abstract class AbstractVodEditPageState extends EditStreamPageTV<AbstractVodEditPage> {
  String appBarTitle() => 'Edit stream';

  VodStream stream() => widget.stream;

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
