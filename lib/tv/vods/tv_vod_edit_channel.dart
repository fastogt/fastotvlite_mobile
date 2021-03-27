import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/tv/add_streams/tv_edit_channel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class AbstractVodEditPage extends StatefulWidget {
  final VodStream stream;

  const AbstractVodEditPage(this.stream);
}

abstract class AbstractVodEditPageState extends EditStreamPageTV<AbstractVodEditPage> {
  @override
  String appBarTitle() => 'Edit stream';

  @override
  VodStream stream() => widget.stream;

  @override
  Widget editingPage() {
    final size = MediaQuery
        .of(context)
        .size;
    return Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
          PreviewIcon.vod(iconController.text),
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

class VodAddPageTV extends AbstractVodEditPage {
  const VodAddPageTV(stream) : super(stream);

  @override
  _VodAddPageTVState createState() => _VodAddPageTVState();
}

class _VodAddPageTVState extends AbstractVodEditPageState {
  @override
  Widget deleteButton() => const SizedBox();
}

class VodEditPageTV extends AbstractVodEditPage {
  const VodEditPageTV(stream) : super(stream);

  @override
  _VodEditPageTVState createState() => _VodEditPageTVState();
}

class _VodEditPageTVState extends AbstractVodEditPageState {}
