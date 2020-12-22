import 'package:fastotvlite/channels/istream.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

abstract class EditStreamPageState<T extends StatefulWidget> extends State<T> {
  TextEditingController iarcController;
  final GlobalKey<TagsState> _groupsStateKey = GlobalKey<TagsState>();
  List<String> groups = [];

  bool validator = true;

  void onSave();

  String appBarTitle();

  Widget editingPage();

  IStream stream();

  @override
  void initState() {
    super.initState();
    groups = stream().groups();
    iarcController = TextEditingController(text: stream().iarc().toString());
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final appBarTextColor = Theming.of(context).onCustomColor(primaryColor);
    return WillPopScope(
      onWillPop: () async {
        exitAndResetChanges();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(color: appBarTextColor),
              title: Text(appBarTitle(), style: TextStyle(color: appBarTextColor)),
              leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => exitAndResetChanges()),
              actions: <Widget>[deleteButton()]),
          floatingActionButton: _saveButton(),
          body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16.0), child: editingPage()))),
    );
  }

  void exitAndResetChanges() => Navigator.of(context).pop(stream());

  Widget _saveButton() {
    final accentColor = Theme.of(context).accentColor;
    return !validator
        ? null
        : FloatingActionButton(
            onPressed: () {
              onSave();
              exitAndResetChanges();
            },
            backgroundColor: accentColor,
            child: Icon(Icons.save, color: Theming.of(context).onCustomColor(accentColor)));
  }

  Widget textField(String hintText, TextEditingController controller, {void Function() onSubmitted}) {
    return new TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: hintText),
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        onFieldSubmitted: (String text) {
          if (onSubmitted != null) {
            onSubmitted();
          }
        });
  }

  Widget deleteButton() {
    return IconButton(icon: Icon(Icons.delete), onPressed: () => Navigator.of(context).pop());
  }

  Widget groupsField() {
    return Tags(
        key: _groupsStateKey,
        textField: TagsTextField(
            hintText: 'Add group',
            constraintSuggestion: false,
            suggestions: [],
            onSubmitted: (String str) {
              setState(() {
                groups.add(str);
              });
            }),
        itemCount: groups.length,
        itemBuilder: (int index) {
          final item = groups[index];

          return ItemTags(
              // Each ItemTags must contain a Key. Keys allow Flutter to
              // uniquely identify widgets.
              key: Key(index.toString()),
              index: index,
              title: item,
              combine: ItemTagsCombine.withTextBefore,
              icon: ItemTagsIcon(icon: Icons.add),
              removeButton: ItemTagsRemoveButton(onRemoved: () {
                setState(() {
                  groups.removeAt(index);
                });
                return true;
              }));
        });
  }
}
