import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'config/network_config.dart';
import 'config/user_preferences.dart';
import 'storage/auth_storage.dart';
import '../features/auth/domain/models/user.dart';

/// 应用配置 - 统一配置入口
///
/// 组合使用各个配置模块，提供统一的访问接口
///
/// 使用示例：
/// ```dart
/// final config = getIt<AppConfig>();
///
/// // 访问网络配置
/// print(config.networkBaseUrl);
///
/// // 访问用户偏好
/// config.setThemeMode(ThemeMode.dark);
///
/// // 访问认证存储
/// final user = config.currentUser.value;
/// ```
class AppConfig {
  // 用户偏好
  final UserPreferences preferences;

  // 认证存储
  final AuthStorage auth;

  // 当前用户（本地信号，同步 auth.currentUser）
  final currentUser = signal<User?>(null);

  AppConfig(this.preferences, this.auth) {
    // 同步认证存储的用户信息
    currentUser.value = auth.currentUser.value;
    auth.currentUser.addListener(() {
      currentUser.value = auth.currentUser.value;
    });
  }

  // ========== 便捷访问属性（网络配置）==========

  /// API 基础 URL
  String get networkBaseUrl => NetworkConfig.baseUrl;

  /// 连接超时（毫秒）
  int get networkConnectTimeout => NetworkConfig.connectTimeout;

  /// 接收超时（毫秒）
  int get networkReceiveTimeout => NetworkConfig.receiveTimeout;

  /// 默认请求头
  Map<String, String> get networkDefaultHeaders => NetworkConfig.defaultHeaders;

  // ========== 便捷访问属性（用户偏好）==========

  /// 当前主题模式
  ThemeMode get currentMode => preferences.currentMode;

  /// 是否启用调试日志
  bool get debugLoggingEnabled => preferences.enableDebugLogging.value;

  /// API 超时时间（秒）
  int get apiTimeout => preferences.apiTimeout.value;

  /// 默认分页大小
  int get defaultPageSize => preferences.defaultPageSize.value;

  // ========== 便捷访问属性（认证）==========

  /// 是否已登录
  bool get isLoggedIn => auth.isLoggedIn;

  /// 当前用户 ID
  int? get currentUserId => auth.currentUserId;

  // ========== 便捷方法 ==========

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) => preferences.setThemeMode(mode);

  /// 设置调试日志
  void setDebugLogging(bool enabled) => preferences.setDebugLogging(enabled);

  /// 设置 API 超时
  void setApiTimeout(int seconds) => preferences.setApiTimeout(seconds);

  /// 设置分页大小
  void setDefaultPageSize(int size) => preferences.setDefaultPageSize(size);

  /// 登出
  Future<void> logout() async {
    await auth.clearAuth();
  }
}
