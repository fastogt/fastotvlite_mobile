import 'package:fastotvlite/localization/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/widgets.dart';

class NoPrograms extends StatelessWidget {
  final Color color;

  const NoPrograms(this.color);

  @override
  Widget build(BuildContext context) {
    return NonAvailableBuffer(
        icon: Icons.error_outline,
        message: AppLocalizations.of(context).translate(TR_NO_PROGRAMS),
        iconSize: 16,
        textSize: 16,
        color: color);
  }
}
