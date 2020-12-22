import 'package:fastotvlite/theme/theme.dart';
import 'package:flutter/material.dart';

class CustomIcons extends StatelessWidget {
  final Function() onTap;
  final IconData icon;

  const CustomIcons(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon), onPressed: () => onTap(), color: Theming.of(context).onBrightness());
  }
}
