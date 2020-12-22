import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotvlite/base/streams/live_timeline.dart';
import 'package:fastotvlite/base/streams/program_bloc.dart';
import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/mobile/streams/live_edit_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/favorite_button.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

abstract class ILiveFutureTileObserver {
  void onTap(List<LiveStream> streams, int position);

  void onLongTap(LiveStream stream);

  void onDelete(LiveStream stream);

  void onAddFavorite(LiveStream stream);

  void onDeleteFavorite(LiveStream stream);
}

class LiveFutureTile extends StatefulWidget {
  final List<LiveStream> channels;
  final int index;
  final ILiveFutureTileObserver observer;

  LiveFutureTile({this.channels, this.index, this.observer});

  @override
  _LiveFutureTileState createState() => _LiveFutureTileState();
}

class _LiveFutureTileState extends State<LiveFutureTile> {
  ProgramsBloc programsBloc;

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
    var channel = widget.channels[widget.index];

    return Container(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
          leading: PreviewIcon.live(channel.icon(), height: 40, width: 40),
          title: Text(AppLocalizations.toUtf8(channel.displayName())),
          subtitle: programNameWidget(),
          onTap: () {
            if (widget.observer != null) {
              widget.observer.onTap(widget.channels, widget.index);
            }
          },
          onLongPress: () async {
            final epgUrl = channel.epgUrl();
            LiveStream response =
                await Navigator.of(context).push(MaterialPageRoute(builder: (context) => LiveEditPage(channel)));
            if (response != null) {
              if (response.epgUrl() != epgUrl) {
                channel.setRequested(false);
                programsBloc = ProgramsBloc(channel);
              }
            }
            if (widget.observer != null) {
              if (response == null) {
                widget.observer.onDelete(channel);
              }
              widget.observer.onLongTap(channel);
            }
          },
          trailing: FavoriteStarButton(
            channel.favorite(),
            onFavoriteChanged: (bool value) => handleFavorite(value),
          )),
      Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[timeLine()])
    ]));
  }

  void handleFavorite(bool value) {
    final channel = widget.channels[widget.index];
    channel.setFavorite(value);
    channel.favorite() ? widget.observer.onAddFavorite(channel) : widget.observer.onDeleteFavorite(channel);
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
          return Text('Loading...', softWrap: true, maxLines: 3);
        }
        return Text(
          title(snapshot.data),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget timeLine() {
    final width = MediaQuery.of(context).size.width;
    return StreamBuilder<ProgrammeInfo>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }
          return LiveTimeLine(programmeInfo: snapshot.data, width: width, height: 2);
        });
  }
}
