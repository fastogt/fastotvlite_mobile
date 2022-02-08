import 'package:fastotvlite/channels/live_stream.dart';
import 'package:fastotvlite/channels/vod_stream.dart';
import 'package:fastotvlite/mobile/mobile_home.dart';
import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:fastotvlite/theme/theme.dart';
import 'package:fastotvlite/tv/tv_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale savedLocale = const Locale('en', 'US');
  List<LiveStream> channels = [];
  List<VodStream> vods = [];

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _loadStreams();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: {LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()},
        child: AppLocalizations(
            init: savedLocale,
            locales: {
              const Locale('en', 'US'): 'English',
              const Locale('ru', 'RU'): 'Русский',
              const Locale('fr', 'CA'): 'Français',
              const Locale('es', 'ES'): 'Español'
            },
            child: Builder(builder: (context) {
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: Theming.of(context).theme,
                  supportedLocales: AppLocalizations.of(context)!.supportedLocales,
                  // These delegates make sure that the localization data for the proper language is loaded
                  localizationsDelegates: [
                    AppLocalizations.of(context)!.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate
                  ],
                  locale: AppLocalizations.of(context)!.currentLocale,
                  localeResolutionCallback: (locale, supportedLocales) {
                    for (final supportedLocale in supportedLocales) {
                      if (supportedLocale != null && locale != null) {
                        if (supportedLocale.languageCode == locale.languageCode &&
                            supportedLocale.countryCode == locale.countryCode) {
                          return supportedLocale;
                        }
                      }
                    }
                    return supportedLocales.first;
                  },
                  home: home());
            })));
  }

  Widget home() {
    final device = locator<RuntimeDevice>();
    return device.hasTouch ? HomeMobile(channels, vods) : HomeTV(channels, vods);
  }

  void _loadLocale() {
    final settings = locator<LocalStorageService>();
    final langCode = settings.langCode();
    final countryCode = settings.countryCode();
    if (langCode != null && countryCode != null) {
      savedLocale = Locale(langCode, countryCode);
    }
  }

  void _loadStreams() {
    final settings = locator<LocalStorageService>();
    channels = settings.liveChannels();
    vods = settings.vods();
  }
}
