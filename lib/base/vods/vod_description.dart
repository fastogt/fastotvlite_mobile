import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/mobile/vods/vod_player_page.dart';
import 'package:fastotvlite/mobile/vods/vod_trailer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/vods/vod_description.dart';

class SideInfo extends StatelessWidget {
  final int duration;
  final int primeDate;
  final String country;
  final double fontSize;
  final ScrollController scrollController;

  const SideInfo(
      {this.country, this.duration, this.primeDate, this.fontSize, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final pd = DateTime.fromMillisecondsSinceEpoch(primeDate);
    final List<Widget> info = [
      _sideDescription(translate(context, TR_COUNTRY), data: country),
      _sideDescription(translate(context, TR_DURATION), data: _getDuration(duration)),
      _sideDescription(translate(context, TR_YEAR), data: pd.year.toString())
    ];
    return SingleChildScrollView(
        controller: scrollController ?? ScrollController(),
        scrollDirection: Axis.horizontal,
        child: Row(children: info));
  }

  // private:
  String _getDuration(int msec) {
    final now = DateTime.now();
    return TimeParser.hm(msec - now.timeZoneOffset.inMilliseconds);
  }

  Widget _sideDescription(String title, {String data}) {
    return SideInfoItem(title: AppLocalizations.toUtf8(title ?? ''), data: data);
  }
}

class VodTrailerButton extends StatelessWidget {
  final VodStream channel;
  final FocusNode focus;

  const VodTrailerButton(this.channel, {this.focus});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        focusNode: focus,
        style: OutlinedButton.styleFrom(
            shape: StadiumBorder(side: BorderSide(width: 2, color: Theme.of(context).accentColor))),
        child: Center(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Text(translate(context, TR_TRAILER))])),
        onPressed: () {
          return _onTrailer(context);
        });
  }

  // private:
  void _onTrailer(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VodTrailer(translate(context, TR_TRAILER) + ": " + channel.displayName(),
          channel.trailerUrl(), channel.previewIcon());
    }));
  }
}

class VodPlayButton extends StatelessWidget {
  final FocusNode focus;
  final VodStream channel;
  final void Function() onTap;

  const VodPlayButton(this.channel, {this.onTap, this.focus});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        focusNode: focus,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        child: Center(child: Text(translate(context, TR_PLAY))),
        onPressed: () {
          _onTapped(context, channel);
        });
  }

  void _onTapped(BuildContext context, VodStream channel) async {
    if (onTap != null) {
      onTap();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VodPlayer(channel);
      }));
    }
  }
}

class DescriptionText extends StatelessWidget {
  final String text;
  final ScrollController scrollController;
  final double textSize;
  final Color textColor;

  const DescriptionText(this.text, {this.scrollController, this.textColor, this.textSize});

  @override
  Widget build(BuildContext context) {
    return text?.isEmpty ?? false
        ? Center(
            child: NonAvailableBuffer(
            message: translate(context, TR_NO_DESCRIPTION),
            color: textColor,
            icon: Icons.description,
          ))
        : SingleChildScrollView(
            controller: scrollController ?? ScrollController(),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(AppLocalizations.toUtf8(text),
                    style: TextStyle(fontSize: textSize ?? 16, color: textColor))));
  }
}
