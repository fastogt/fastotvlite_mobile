import 'package:fastotv_device_info/devices.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

const DEVELOPER_SETTINGS_COUNTER = 7;

class DebugQueryInfo extends StatelessWidget {
  const DebugQueryInfo();

  List<Widget> get _device {
    final device = locator<RuntimeDevice>();
    final android = device.androidDetails;
    final green = TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold);
    final red = TextStyle(color: Colors.red[400]);
    final estimatedColor = device.isRegisteredInOurDB() ? green : red;
    if (android != null) {
      return <Widget>[
        Text("Estimated Device: ${device.name}", style: estimatedColor),
        Text("os: ${device.os}"),
        Text("brand: ${android.brand}"),
        Text("device: ${android.device}"),
        Text("display: ${android.display}"),
        Text("manufacturer: ${android.manufacturer}", style: red),
        Text("model: ${android.model}", style: red),
        Text("fingerprint: ${android.fingerprint}"),
        Text("version: ${android.version}"),
        Text("has touch: ${device.hasTouch}", style: red)
      ];
    }

    final ios = device.iosDetails;
    if (ios != null) {
      return <Widget>[
        Text("Estimated Device: ${device.name}", style: estimatedColor),
        Text("os: ${device.os}"),
        Text("model: ${ios.utsname.machine}", style: red),
        Text("manufacturer: $APPLE_BRAND", style: red),
        Text("name: ${ios.name}"),
        Text("systemName: ${ios.systemName}"),
        Text("systemVersion: ${ios.systemVersion}"),
        Text("localizedModel: ${ios.localizedModel}"),
        Text(
            "utsname: ${ios.utsname.sysname}\n${ios.utsname.nodename}\n${ios.utsname.release}\n${ios.utsname.version}\n${ios.utsname.machine}"),
        Text("has touch: ${device.hasTouch}", style: red)
      ];
    }

    return <Widget>[];
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final red = TextStyle(color: Colors.red[400]);
    return Scaffold(
        appBar: AppBar(
            leading: Padding(
                padding: const EdgeInsets.all(4.0),
                child: IconButton(
                    focusColor: Colors.amber,
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 32,
                    color: Theming.of(context).onPrimary(),
                    onPressed: Navigator.of(context).pop)),
            title: Text(AppLocalizations.toUtf8('Device info'),
                style: TextStyle(color: Theming.of(context).onPrimary()))),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(
                children: _device
                  ..addAll([
                    Text("devicePixelRatio: ${media.devicePixelRatio}", style: red),
                    Text("padding: ${media.padding}", style: red),
                    Text("size: ${media.size}", style: red),
                    Text("viewInsets: ${media.viewInsets}"),
                    Text("textScaleFactor: ${media.textScaleFactor}"),
                    Text("platformBrightness: ${media.platformBrightness}"),
                    Text("boldText: ${media.boldText}")
                  ]))));
  }
}

class VersionTile extends StatefulWidget {
  final int type;

  const VersionTile.settings() : type = 0;

  const VersionTile.login() : type = 1;

  @override
  VersionTileState createState() {
    return VersionTileState();
  }
}

class VersionTileState extends State<VersionTile> {
  int counter = 0;

  void toInfo() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const DebugQueryInfo()));
    counter = 0;
  }

  Widget _login(String version) {
    return Opacity(opacity: 0.5, child: TextButton(child: Text(version), onPressed: _increment));
  }

  Widget _settings(String version) {
    return ListTile(
        leading: Icon(Icons.info, color: Theming.of(context).onBrightness()),
        title: Text(AppLocalizations.of(context)!.translate(TR_VERSION)!),
        subtitle: Text(version),
        onTap: _increment);
  }

  @override
  Widget build(BuildContext context) {
    final package = locator<PackageManager>();
    final version = package.version();
    if (widget.type == 0) {
      return _settings(version);
    }
    if (widget.type == 1) {
      return _login(version);
    }
    return const SizedBox();
  }

  void _increment() {
    counter++;
    if (counter == DEVELOPER_SETTINGS_COUNTER) {
      toInfo();
    }
  }
}
