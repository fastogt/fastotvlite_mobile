import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/mobile/vods/vod_player_page.dart';
import 'package:fastotvlite/mobile/vods/vod_trailer_page.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/base/controls/no_channels.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/runtime_device.dart';
import 'package:flutter_fastotv_common/base/vods/vod_description.dart';

class SideInfo extends StatelessWidget {
  final int duration;
  final int primeDate;
  final String country;
  final double fontSize;
  final ScrollController scrollController;

  SideInfo({this.country, this.duration, this.primeDate, this.fontSize, this.scrollController});

  String getDuration(int msec) {
    String twoDigits(int n) {
      if (n >= 10) {
        return "$n";
      }
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(Duration(milliseconds: msec).inMinutes.remainder(60));
    return '${twoDigits(Duration(milliseconds: msec).inHours)}:$twoDigitMinutes';
  }

  Widget sideDescription(String title, {String data}) =>
      SideInfoItem(title: AppLocalizations.toUtf8(title), data: data);

  Widget infoBuilder() {
    List<Widget> info = [
      sideDescription('Country', data: country),
      sideDescription('Runtime', data: getDuration(duration)),
      sideDescription('Year', data: DateTime.fromMillisecondsSinceEpoch(primeDate).year.toString())
    ];
    return SingleChildScrollView(
        controller: scrollController ?? ScrollController(),
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: info));
  }

  @override
  Widget build(BuildContext context) {
    return infoBuilder();
  }
}

class VodTrailerButton extends StatelessWidget {
  final VodStream channel;
  final FocusNode focus;

  const VodTrailerButton(this.channel, {this.focus});

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    final device = locator<RuntimeDevice>();
    if (device.hasTouch) {
      buttonColor = Theme.of(context).accentColor;
    } else {
      buttonColor = Theming.of(context).onBrightness();
    }
    return RaisedButton(
      focusNode: focus,
      focusColor: Theme.of(context).accentColor,
      elevation: 0,
      onPressed: () {
        return _onTrailer(context);
      },
      color: Colors.transparent,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: buttonColor, width: 2)),
      child: Center(child: Text('Trailer')),
    );
  }

  // private:
  void _onTrailer(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VodTrailer(
          "Trailer: ${channel.displayName()}", channel.trailerUrl(), channel.previewIcon());
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
    Color buttonColor;
    final device = locator<RuntimeDevice>();
    if (device.hasTouch) {
      buttonColor = Theme.of(context).accentColor;
    } else {
      buttonColor = Theming.of(context).onBrightness();
    }
    final textColor = Theming.of(context).onCustomColor(buttonColor);
    return RaisedButton(
        focusNode: focus,
        focusColor: Theme.of(context).accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onPressed: () {
          _onTapped(context, channel);
        },
        color: buttonColor,
        child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text('Play', style: TextStyle(fontSize: 14, color: textColor))
        ])));
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
            message: 'No description',
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
