import 'package:fastotvlite/base/login/textfields.dart';
import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/localization/app_localizations.dart';
import 'package:flutter_common/tv/key_code.dart';

abstract class EditStreamPageTV<T extends StatefulWidget> extends State<T> {
  FocusNode currentNode;

  final backButtonNode = FocusNode();
  final saveButtonNode = FocusNode();
  final deleteButtonNode = FocusNode();

  TextEditingController nameController;
  TextEditingController videoLinkController;
  TextEditingController iconController;
  TextEditingController iarcController;

  final nameFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final urlFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final iconFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
  final iarcFieldNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));

  bool validator = true;

  void onSave();

  String appBarTitle();

  Widget editingPage();

  IStream stream();

  void enterAction(FocusNode node);

  @override
  void initState() {
    super.initState();
    currentNode = backButtonNode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(currentNode);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final appBarTextColor = Theming.of(context).onCustomColor(primaryColor);
    return WillPopScope(
        onWillPop: () async {
          exitAndResetChanges();
        },
        child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                iconTheme: IconThemeData(color: appBarTextColor),
                centerTitle: true,
                title: Text(AppLocalizations.toUtf8(appBarTitle()), style: TextStyle(color: appBarTextColor)),
                leading: backButton(),
                actions: <Widget>[saveButton(), deleteButton()]),
            backgroundColor: primaryColor,
            body: editingPage()));
  }

  Widget textField(String hintText, TextFieldNode node, TextEditingController controller) {
    return LoginTextField(
        mainFocus: node.main,
        textFocus: node.text,
        textEditingController: controller,
        hintText: hintText,
        obscureText: false,
        onKey: nodeAction,
        validate: controller.text.isNotEmpty,
        onFieldChanged: () {},
        onFieldSubmit: () {
          currentNode = node.main;
          FocusScope.of(context).requestFocus(currentNode);
          setState(() {});
        });
  }

  Widget backButton() {
    return Focus(focusNode: backButtonNode, onKey: nodeAction, child: _icon(Icons.arrow_back, backButtonNode));
  }

  Widget saveButton() {
    return Focus(
        focusNode: saveButtonNode,
        onKey: nodeAction,
        child: Padding(padding: EdgeInsets.all(16.0), child: _icon(Icons.save, saveButtonNode)));
  }

  Widget deleteButton() {
    return Focus(
        focusNode: saveButtonNode,
        onKey: nodeAction,
        child: IconButton(icon: _icon(Icons.delete, deleteButtonNode), onPressed: () => exitAndDelete()));
  }

  Widget _icon(IconData icon, FocusNode node) {
    return Icon(icon, color: node.hasPrimaryFocus ? Theme.of(context).accentColor : null);
  }

  bool nodeAction(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      switch (rawKeyEventDataAndroid.keyCode) {
        case ENTER:
        case KEY_CENTER:
          enterAction(node);
          break;
        case KEY_LEFT:
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          break;
        case KEY_RIGHT:
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
          break;
        case KEY_UP:
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          break;
        case KEY_DOWN:
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          break;
        default:
          break;
      }
      currentNode = FocusScope.of(context).focusedChild;
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  void setFocus(FocusNode node) {
    currentNode = node;
    FocusScope.of(context).requestFocus(currentNode);
  }

  void exitAndSaveChanges() {
    onSave();
    Navigator.of(context).pop(stream());
  }

  void exitAndResetChanges() {
    Navigator.of(context).pop(stream());
  }

  void exitAndDelete() {
    Navigator.of(context).pop();
  }
}
