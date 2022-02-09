import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/localization/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';

enum EditResult { ADD, EDIT, DELETE }

abstract class EditStreamPage<T extends IStream> extends StatefulWidget {
  final T stream;

  const EditStreamPage(this.stream);
}

abstract class EditStreamPageState<T extends IStream> extends State<EditStreamPage<T>> {
  static const int DEFAULT_IARC = 18;

  late TextEditingController nameController;
  late TextEditingController iconController;
  late TextEditingController videoLinkController;
  late TextEditingController iarcController;

  List<String> groups = [];

  bool validator = true;

  String get appBarTitle;

  @override
  void initState() {
    super.initState();
    groups = widget.stream.groups();
    nameController =
        TextEditingController(text: AppLocalizations.toUtf8(widget.stream.displayName()));
    iconController = TextEditingController(text: widget.stream.icon());
    videoLinkController = TextEditingController(text: widget.stream.primaryUrl());
    iarcController = TextEditingController(text: widget.stream.iarc().toString());
    validator = videoLinkController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final appBarTextColor = backgroundColorBrightness(primaryColor);
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: appBarTextColor),
            actionsIconTheme: IconThemeData(color: appBarTextColor),
            title: Text(translate(context, appBarTitle), style: TextStyle(color: appBarTextColor)),
            leading: const BackButton(),
            actions: <Widget>[deleteButton()]),
        floatingActionButton: _saveButton(),
        body: SingleChildScrollView(
            child:
                Padding(padding: const EdgeInsets.all(16.0), child: Column(children: content()))));
  }

  List<Widget> content() {
    return <Widget>[
      Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.shortestSide,
              maxHeight: MediaQuery.of(context).size.shortestSide),
          child: PreviewIcon.live(iconController.text)),
      textField(TR_EDIT_TITLE, nameController),
      groupsField(),
      textField(TR_EDIT_VIDEO_LINK, videoLinkController, onSubmitted: _validate),
      textField(TR_EDIT_ICON, iconController, onSubmitted: _updateIcon),
      textField('IARC', iarcController)
    ];
  }

  Widget? _saveButton() {
    final accentColor = Theme.of(context).colorScheme.secondary;
    return !validator
        ? null
        : FloatingActionButton(
            onPressed: onSave,
            backgroundColor: accentColor,
            child: Icon(Icons.save, color: backgroundColorBrightness(accentColor)));
  }

  Widget textField(String hintText, TextEditingController controller,
      {void Function()? onSubmitted}) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: translate(context, hintText)),
        keyboardType: TextInputType.text,
        onFieldSubmitted: (String text) {
          onSubmitted?.call();
        });
  }

  Widget deleteButton() {
    return IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          widget.stream.setId('');
          Navigator.of(context).pop(widget.stream);
        });
  }

  Widget groupsField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ChipListField(
        values: groups,
        hintText: 'Groups',
        onItemAdded: (value) => setState(() => groups.add(value)),
        onItemRemoved: (index) => setState(() => groups.removeAt(index)),
      ),
    );
  }

  void _validate() {
    setState(() {
      validator = videoLinkController.text.isNotEmpty;
    });
  }

  void _updateIcon() {
    setState(() {});
  }

  void onSave() {
    widget.stream.setDisplayName(nameController.text);
    widget.stream.setPrimaryUrl(videoLinkController.text);
    widget.stream.setIcon(iconController.text);
    widget.stream.setIarc(int.tryParse(iarcController.text) ?? DEFAULT_IARC);
    widget.stream.setGroups(groups);
    Navigator.of(context).pop(widget.stream);
  }
}
