import 'package:fastotv_dart/commands_info/device_info.dart';
import 'package:fastotvlite/base/login/textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization/app_localizations.dart';

class DevicePicker extends StatefulWidget {
  final List<DeviceInfo> devices;
  final int initIndex;

  final ScrollController scrollController;
  final void Function(int) onChanged;
  final FocusNode listFocus;
  final Color activeColor;

  DevicePicker({this.devices, this.initIndex, this.scrollController, this.onChanged, this.listFocus, this.activeColor});

  @override
  _DevicePickerState createState() => _DevicePickerState();
}

class _DevicePickerState extends State<DevicePicker> {
  @override
  Widget build(BuildContext context) {
    return Material(
      shape: border(context, widget.listFocus),
      child: ListView.builder(
          controller: widget.scrollController,
          itemCount: widget.devices.length,
          itemExtent: 56,
          itemBuilder: (context, index) => RadioListTile(
              onChanged: (int index) => widget.onChanged(index),
              value: index,
              groupValue: widget.initIndex,
              activeColor: widget.activeColor,
              title: Text(AppLocalizations.toUtf8(widget.devices[index].name),
                  style: TextStyle(fontWeight: widget.initIndex == index ? FontWeight.bold : FontWeight.normal),
                  overflow: TextOverflow.ellipsis))),
    );
  }
}
