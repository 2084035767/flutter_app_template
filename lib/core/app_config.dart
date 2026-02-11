import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

@Singleton()
class AppConfig {
  final SharedPreferences prefs;

  AppConfig(this.prefs);

  static String baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.example.com';
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
  static const int retryDelaysTimeout = 500;
  static const int retries = 3;
  static Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  final themeMode = signal<ThemeMode>(ThemeMode.system);
  final enableDebugLogging = signal<bool>(true);
  final apiTimeout = signal<int>(30000);
  final defaultPageSize = signal<int>(20);
  ThemeMode get currentMode => themeMode.value;

  static const String _keyThemeMode = 'app.theme.mode';
  static const String _keyDebugLogging = 'app.debug.logging';
  static const String _keyApiTimeout = 'app.api.timeout';
  static const String _keyDefaultPageSize = 'app.default.page.size';

  @PostConstruct()
  Future<void> init() async {
    await dotenv.load();
    final int themeIndex =
        prefs.getInt(_keyThemeMode) ?? ThemeMode.system.index;
    final int resolvedIndex =
        themeIndex >= 0 && themeIndex < ThemeMode.values.length
        ? themeIndex
        : ThemeMode.system.index;
    themeMode.value = ThemeMode.values[resolvedIndex];
    enableDebugLogging.value = prefs.getBool(_keyDebugLogging) ?? false;
    apiTimeout.value = prefs.getInt(_keyApiTimeout) ?? 30;
    defaultPageSize.value = prefs.getInt(_keyDefaultPageSize) ?? 20;
  }

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    prefs.setInt(_keyThemeMode, mode.index);
  }

  /// 设置调试日志开关
  void setDebugLogging(bool enabled) {
    enableDebugLogging.value = enabled;
    prefs.setBool(_keyDebugLogging, enabled);
  }

  /// 设置API超时时间
  void setApiTimeout(int timeout) {
    apiTimeout.value = timeout;
    prefs.setInt(_keyApiTimeout, timeout);
  }

  /// 设置默认分页大小
  void setDefaultPageSize(int size) {
    defaultPageSize.value = size;
    prefs.setInt(_keyDefaultPageSize, size);
  }
}
