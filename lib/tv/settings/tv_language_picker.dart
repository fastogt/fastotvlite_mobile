import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class LanguagePickerTV extends StatefulWidget {
  const LanguagePickerTV();

  @override
  _LanguagePickerTVState createState() {
    return _LanguagePickerTVState();
  }
}

class _LanguagePickerTVState extends State<LanguagePickerTV> {
  int _currentSelection = 0;

  List<String> get supportedLanguages => AppLocalizations.of(context)!.supportedLanguages;

  List<Locale> get supportedLocales => AppLocalizations.of(context)!.supportedLocales;

  @override
  Widget build(BuildContext context) {
    _currentSelection = currentLanguageIndex();
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(supportedLanguages.length,
            (int index) => _dialogItem(supportedLanguages[index], index)));
  }

  Widget _dialogItem(String text, int itemvalue) {
    return RadioListTile(
        activeColor: Theme.of(context).colorScheme.secondary,
        title: Text(text, style: const TextStyle(fontSize: 20)),
        value: itemvalue,
        groupValue: _currentSelection,
        onChanged: _changeLanguage);
  }

  void _changeLanguage(int? value) async {
    if (value == null) {
      return;
    }

    _currentSelection = value;
    final selectedLocale = supportedLocales[value];
    AppLocalizations.of(context)!.load(selectedLocale);
    final settings = locator<LocalStorageService>();
    settings.setLangCode(selectedLocale.languageCode);
    settings.setCountryCode(selectedLocale.countryCode);
    setState(() {});
  }

  int currentLanguageIndex() {
    return supportedLocales.indexOf(AppLocalizations.of(context)!.currentLocale) ?? 0;
  }
}
