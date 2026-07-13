import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database/app_database.dart';

@module
abstract class CoreModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  AppDatabase get database => AppDatabase();
}
