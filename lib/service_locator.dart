import 'package:fastotvlite/events/search_events.dart';
import 'package:fastotvlite/events/stream_list_events.dart';
import 'package:fastotvlite/events/tv_events.dart';
import 'package:fastotvlite/shared_prefs.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:get_it/get_it.dart';

// https://www.filledstacks.com/snippet/shared-preferences-service-in-flutter-for-code-maintainability/

GetIt locator = GetIt.instance;

Future setupLocator() async {
  final device = await RuntimeDevice.getInstance();
  locator.registerSingleton<RuntimeDevice>(device);

  final clientEvents = await StreamListEvent.getInstance();
  locator.registerSingleton<StreamListEvent>(clientEvents);

  final tvTabEvents = await TvTabsEvents.getInstance();
  locator.registerSingleton<TvTabsEvents>(tvTabEvents);

  final storage = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(storage);

  final package = await PackageManager.getInstance();
  locator.registerSingleton<PackageManager>(package);

  final time = await TimeManager.getInstance();
  locator.registerSingleton<TimeManager>(time);

  final searchEvents = await SearchEvents.getInstance();
  locator.registerSingleton<SearchEvents>(searchEvents);
}
