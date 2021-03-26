import 'package:fastotvlite/base/vods/constants.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/mobile/mobile_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fastotv_common/base/vods/vod_card.dart';

class VodStreamSearch extends IStreamSearchDelegate<VodStream> {
  VodStreamSearch(List<VodStream> streams, String hint) : super(streams, hint);

  @override
  Widget list(List<VodStream> results) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: CARD_WIDTH + 2 * EDGE_INSETS,
                    crossAxisSpacing: EDGE_INSETS,
                    mainAxisSpacing: EDGE_INSETS,
                    childAspectRatio: 2 / 3),
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) {
                  final channel = results[index];
                  return VodCard(
                      iconLink: channel.icon(),
                      duration: channel.duration(),
                      interruptTime: channel.interruptTime(),
                      width: CARD_WIDTH,
                      onPressed: () => close(context, results[index]));
                })));
  }
}
