import 'package:fastotvlite/localization/translations.dart';
import 'package:fastotvlite/pages/debug_page.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/theming.dart';

class AboutPage extends StatefulWidget {
  final String login;
  final DateTime expDate;
  final String deviceID;

  AboutPage(this.login, this.expDate, this.deviceID);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  TextStyle mainTextStyle = TextStyle(fontSize: 16);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _snackBarShown = false;

  final divider = Divider(height: 0.0);

  void copyInfoSnackbar(String toCopy, String whatCopied) {
    if (_snackBarShown) {
      _snackBarShown = false;
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    _snackBarShown = true;
    Clipboard.setData(new ClipboardData(text: toCopy));
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(whatCopied + ' ' + translate(context, TR_COPIED))))
        .closed
        .then((_) {
      _snackBarShown = false;
    });
  }

  Widget login() {
    return ListTile(
        leading: Icon(Icons.account_box, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_LOGIN_ABOUT)),
        subtitle: Text(widget.login),
        onTap: () {
          copyInfoSnackbar(widget.login, translate(context, TR_LOGIN_ABOUT));
        });
  }

  Widget expDate() {
    return ListTile(
      leading: Icon(Icons.date_range, color: Theming.of(context).onBrightness()),
      title: Text(translate(context, TR_EXPIRATION_DATE)),
      subtitle: Text(widget.expDate.toString()),
      onTap: () {},
    );
  }

  Widget deviceID() {
    return ListTile(
        leading: Icon(Icons.perm_device_information, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_DEVICE_ID)),
        subtitle: Text(widget.deviceID),
        onTap: () {
          copyInfoSnackbar(widget.deviceID, 'ID');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            iconTheme: IconThemeData(color: Theming.of(context).onPrimary()),
            title: Text(translate(context, TR_ABOUT), style: TextStyle(color: Theming.of(context).onPrimary()))),
        body: Column(children: <Widget>[
          ListHeader(text: translate(context, TR_ACCOUNT)),
          login(),
          expDate(),
          deviceID(),
          divider,
          ListHeader(text: translate(context, TR_APP)),
          VersionTile.settings()
        ]));
  }
}
