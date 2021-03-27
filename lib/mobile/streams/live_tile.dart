import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/base/streams/live_timeline.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/mobile/streams/live_edit_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class ILiveFutureTileObserver {
  void onTap(List<LiveStream> streams, int position);

  void edit(LiveStream stream, List<String> prevGroups);

  void delete(LiveStream stream);

  void handleFavorite(bool value, LiveStream stream);
}

class LiveFutureTile extends StatefulWidget {
  final List<LiveStream> channels;
  final int index;
  final ILiveFutureTileObserver observer;

  const LiveFutureTile({this.channels, this.index, this.observer});

  @override
  _LiveFutureTileState createState() => _LiveFutureTileState();
}

class _LiveFutureTileState extends State<LiveFutureTile> {
  ProgramsBloc programsBloc;

  LiveStream get _stream => widget.channels[widget.index];

  @override
  void initState() {
    super.initState();
    final channel = widget.channels[widget.index];
    programsBloc = ProgramsBloc(channel);
  }

  @override
  void dispose() {
    super.dispose();
    programsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
          leading: PreviewIcon.live(_stream.icon(), height: 40, width: 40),
          title: Text(AppLocalizations.toUtf8(_stream.displayName())),
          subtitle: programNameWidget(),
          onTap: onTap,
          onLongPress: onLongPressed,
          trailing: FavoriteStarButton(_stream.favorite(), onFavoriteChanged: handleFavorite)),
      Row(children: <Widget>[timeLine()])
    ]);
  }

  void onTap() {
    if (widget.observer != null) {
      widget.observer.onTap(widget.channels, widget.index);
    }
  }

  void onLongPressed() async {
    final epgUrl = _stream.epgUrl();
    final List<String> oldGroups = [];
    oldGroups.addAll(_stream.groups());
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LiveEditPage(_stream);
    })).then((result) {
      if (result != null) {
        if (result.epgUrl() != epgUrl) {
          _stream.setRequested(false);
          programsBloc = ProgramsBloc(_stream);
        }
        if (result.id() == null) {
          widget.observer.delete(_stream);
        } else {
          widget.observer.edit(_stream, oldGroups);
        }
      }
    });
  }

  void handleFavorite(bool value) {
    widget.observer.handleFavorite(value, _stream);
  }

  Widget programNameWidget() {
    String title(ProgrammeInfo programmeInfo) {
      if (programmeInfo != null) {
        return AppLocalizations.toUtf8(programmeInfo.title);
      }
      return 'N/A';
    }

    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...', softWrap: true, maxLines: 3);
          }
          return Text(title(snapshot.data), maxLines: 1, overflow: TextOverflow.ellipsis);
        });
  }

  Widget timeLine() {
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          return LiveTimeLine(programmeInfo: snapshot.data, width: width, height: 2);
        });
  }
}
