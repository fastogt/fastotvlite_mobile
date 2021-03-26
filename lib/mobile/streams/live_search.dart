import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/mobile/mobile_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

class LiveStreamSearch extends IStreamSearchDelegate<LiveStream> {
  LiveStreamSearch(List<LiveStream> results, String hint) : super(results, hint);

  Widget list(List<LiveStream> results) {
    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) => ListTile(
            leading: PreviewIcon.live(results[index].icon(), height: 40, width: 40),
            title: Text(AppLocalizations.toUtf8(results[index].displayName())),
            onTap: () => close(context, results[index])));
  }
}
