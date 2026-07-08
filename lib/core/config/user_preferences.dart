import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 用户偏好配置
///
/// 负责管理用户相关的配置和偏好设置，使用响应式信号实现状态更新
class UserPreferences {
  late final SharedPreferences _prefs;

  UserPreferences();

  // 主题模式
  final themeMode = signal<ThemeMode>(ThemeMode.system);

  // 调试日志开关
  final enableDebugLogging = signal<bool>(true);

  // API 超时时间（秒）
  final apiTimeout = signal<int>(30);

  // 默认分页大小
  final defaultPageSize = signal<int>(20);

  ThemeMode get currentMode => themeMode.value;

  // 本地存储键名
  static const String _keyThemeMode = 'app.theme.mode';
  static const String _keyDebugLogging = 'app.debug.logging';
  static const String _keyApiTimeout = 'app.api.timeout';
  static const String _keyDefaultPageSize = 'app.default.page.size';
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromStorage();
  }

  /// 从本地存储加载用户偏好
  void _loadFromStorage() {
    // 加载主题模式
    final themeIndex =
        _prefs.getInt(_keyThemeMode) ?? ThemeMode.system.index;
    final resolvedIndex =
        themeIndex >= 0 && themeIndex < ThemeMode.values.length
            ? themeIndex
            : ThemeMode.system.index;
    themeMode.value = ThemeMode.values[resolvedIndex];

    // 加载其他偏好
    enableDebugLogging.value = _prefs.getBool(_keyDebugLogging) ?? false;
    apiTimeout.value = _prefs.getInt(_keyApiTimeout) ?? 30;
    defaultPageSize.value = _prefs.getInt(_keyDefaultPageSize) ?? 20;
  }

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _prefs.setInt(_keyThemeMode, mode.index);
  }

  /// 设置调试日志开关
  void setDebugLogging(bool enabled) {
    enableDebugLogging.value = enabled;
    _prefs.setBool(_keyDebugLogging, enabled);
  }

  /// 设置 API 超时时间
  void setApiTimeout(int timeout) {
    apiTimeout.value = timeout;
    _prefs.setInt(_keyApiTimeout, timeout);
  }

  /// 设置默认分页大小
  void setDefaultPageSize(int size) {
    defaultPageSize.value = size;
    _prefs.setInt(_keyDefaultPageSize, size);
  }
}
