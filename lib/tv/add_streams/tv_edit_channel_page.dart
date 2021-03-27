import 'package:fastotvlite/base/login/textfields.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

abstract class EditStreamPageTV<T extends StatefulWidget> extends State<T> {
  static const int DEFAULT_IARC = 18;

  TextEditingController nameController;
  TextEditingController videoLinkController;
  TextEditingController iconController;
  TextEditingController iarcController;

  final nameFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final urlFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final iconFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final iarcFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));

  bool validator = true;

  String appBarTitle();

  Widget editingPage();

  IStream stream();

  @override
  void initState() {
    super.initState();
    iarcController = TextEditingController(text: stream().iarc().toString());
    nameController = TextEditingController(text: AppLocalizations.toUtf8(stream().displayName()));
    iconController = TextEditingController(text: stream().icon());
    videoLinkController = TextEditingController(text: stream().primaryUrl());
    validator = videoLinkController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme
        .of(context)
        .primaryColor;
    final appBarTextColor = backgroundColorBrightness(primaryColor);
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(color: appBarTextColor),
            centerTitle: true,
            title: Text(AppLocalizations.toUtf8(appBarTitle()),
                style: TextStyle(color: appBarTextColor)),
            leading: backButton(),
            actions: <Widget>[saveButton(), deleteButton()]),
        backgroundColor: primaryColor,
        body: editingPage());
  }

  Widget textField(String hintText, TextFieldNode node, TextEditingController controller) {
    return LoginTextField(
        mainFocus: node.main,
        textFocus: node.text,
        controller: controller,
        hintText: hintText,
        obscureText: false,
        onFieldSubmit: (_) {
          setState(() {});
        });
  }

  Widget backButton() {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: exit);
  }

  Widget saveButton() {
    return IconButton(icon: const Icon(Icons.save), onPressed: onSave);
  }

  Widget deleteButton() {
    return IconButton(icon: const Icon(Icons.delete), onPressed: exitAndDelete);
  }

  void exit() {
    Navigator.of(context).pop();
  }

  void exitAndDelete() {
    stream().setId(null);
    Navigator.of(context).pop(stream());
  }

  void onSave() {
    stream().setDisplayName(nameController.text);
    stream().setPrimaryUrl(videoLinkController.text);
    stream().setIcon(iconController.text);
    stream().setIarc(int.tryParse(iarcController.text) ?? DEFAULT_IARC);
    Navigator.of(context).pop(stream());
  }
}
