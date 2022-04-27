import 'package:fastotvlite/service_locator.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

const LIGHT_THEME_ID = 'light_theme'; // mob, tv
const DARK_THEME_ID = 'dark_theme'; // mob, tv
const CUSTOM_LIGHT_THEME_ID = 'custom_light_theme'; // mob
const CUSTOM_DARK_THEME_ID = 'dark_light_theme'; // mob
const BLACK_THEME_ID = 'black_theme'; // tv

class Theming extends StatefulWidget {
  final Widget child;
  final ThemeData? initTheme;

  const Theming({Key? key, required this.child, this.initTheme}) : super(key: key);

  @override
  _ThemingState createState() => _ThemingState();

  static _ThemingState of(BuildContext context, {bool depend = true}) {
    if (depend) {
      return context.dependOnInheritedWidgetOfExactType<_InheritedThemeProvider>()!.data;
    }
    return context.findAncestorStateOfType<_ThemingState>()!;
  }

  static Color onCustomColor(Color background, {Color? dark, Color? light}) {
    if (ThemeData.estimateBrightnessForColor(background) == Brightness.dark) {
      return dark ?? Colors.white;
    } else {
      return light ?? Colors.black;
    }
  }
}

class _ThemingState extends State<Theming> {
  String? _id;

  Color _accentColor = Colors.amber;

  ThemeData lightTheme = ThemeData.light().copyWith(primaryColor: Colors.white);
  ThemeData darkTheme = ThemeData.dark().copyWith(primaryColor: Colors.grey[900]);
  ThemeData customLightTheme = ThemeData.light();
  ThemeData customDarkTheme = ThemeData.dark();
  ThemeData blackTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.black,
      backgroundColor: Colors.black,
      scaffoldBackgroundColor: Colors.black);

  @override
  void initState() {
    super.initState();
    if (widget.initTheme != null) {
      _accentColor = widget.initTheme!.colorScheme.secondary;
      if (widget.initTheme!.brightness == Brightness.light) {
        customLightTheme = widget.initTheme!;
      } else {
        customDarkTheme = widget.initTheme!;
      }
    }
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedThemeProvider(data: this, child: widget.child);
  }

  ThemeData get theme => _getTheme(_id);

  String? get themeId => _id;

  Color onBrightness({Color? dark, Color? light}) {
    if (theme.brightness == Brightness.dark) {
      return dark ?? Colors.white;
    }
    return light ?? Colors.black;
  }

  Color onPrimary({Color? dark, Color? light}) {
    if (ThemeData.estimateBrightnessForColor(theme.primaryColor) == Brightness.dark) {
      return dark ?? Colors.white;
    }
    return light ?? Colors.black;
  }

  Color onAccent({Color? dark, Color? light}) {
    if (ThemeData.estimateBrightnessForColor(theme.colorScheme.secondary) == Brightness.dark) {
      return dark ?? Colors.white;
    }
    return light ?? Colors.black;
  }

  void setTheme(String? newId) {
    _changeTheme(newId!);
    _update();
  }

  void setPrimaryColor(Color color) {
    _changePrimaryColor(color);
    _update();
  }

  void setAccentColor(Color color) {
    _changeAccentColor(color);
    _update();
  }

  // private:
  void _init() async {
    final device = locator<RuntimeDevice>();
    final bool _hasTouch = await device.futureTouch;

    final settings = locator<LocalStorageService>();
    _id = settings.themeID();
    if (_id == null) {
      if (_hasTouch) {
        _id = CUSTOM_DARK_THEME_ID;
      } else {
        _id = DARK_THEME_ID;
      }
    }

    final Color? _primary = settings.getPrimaryColor();
    if (_primary != null) {
      _changePrimaryColor(_primary);
    }

    Color _accent;
    if (_hasTouch) {
      _accent = settings.getAccentColor() ?? _accentColor;
    } else {
      _accent = _accentColor;
    }
    _changeAccentColor(_accent);
    _update();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  void _changeTheme(String newId) {
    _id = newId;
    final settings = locator<LocalStorageService>();
    settings.saveThemeID(_id!);
  }

  void _changePrimaryColor(Color color) {
    final settings = locator<LocalStorageService>();
    settings.savePrimaryColor(color);
    customLightTheme = customLightTheme.copyWith(primaryColor: color);
    customDarkTheme = customDarkTheme.copyWith(primaryColor: color);
  }

  void _changeAccentColor(Color color) {
    final settings = locator<LocalStorageService>();
    settings.saveAccentColor(color);
    lightTheme = lightTheme.setAccent(color);
    darkTheme = darkTheme.setAccent(color);
    customLightTheme = customLightTheme.setAccent(color);
    customDarkTheme = customDarkTheme.setAccent(color);
    blackTheme = blackTheme.setAccent(color);
  }

  ThemeData _getTheme(String? id) {
    switch (id) {
      case LIGHT_THEME_ID:
        return lightTheme;
      case DARK_THEME_ID:
        return darkTheme;
      case CUSTOM_LIGHT_THEME_ID:
        return customLightTheme;
      case CUSTOM_DARK_THEME_ID:
        return customDarkTheme;
      case BLACK_THEME_ID:
        return blackTheme;
      default:
        return lightTheme;
    }
  }
}

extension SetColors on ThemeData {
  ThemeData setAccent(Color color) {
    return copyWith(
      colorScheme: colorScheme.copyWith(secondary: color),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: color, onPrimary: Theming.onCustomColor(color))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(primary: color)),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              primary: brightness == Brightness.dark ? Colors.white : Colors.black)),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: color),
    );
  }
}

class _InheritedThemeProvider extends InheritedWidget {
  final _ThemingState data;

  const _InheritedThemeProvider({
    required this.data,
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedThemeProvider oldWidget) {
    return true;
  }
}
