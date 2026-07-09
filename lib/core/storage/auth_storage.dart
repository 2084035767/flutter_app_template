import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../features/auth/domain/models/user.dart';

/// 认证存储
///
/// 负责管理认证相关的本地存储，包括用户信息和 token
@Singleton()
class AuthStorage {
  late final SharedPreferences _prefs;

  // 当前用户信号
  final currentUser = signal<User?>(null);

  // 本地存储键名
  static const String _keyUser = 'auth.user';
  static const String _keyToken = 'auth.token';
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserFromStorage();
  }

  /// 从本地存储加载用户信息
  void _loadUserFromStorage() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        // 注意：这里需要 User 类支持 fromJson
        // 如果 User 没有实现，可以暂时存储用户 ID 等基本信息
        currentUser.value = User.fromJsonString(userJson);
      } catch (e) {
        // JSON 解析失败，清除存储
        _prefs.remove(_keyUser);
      }
    }
  }

  /// 保存用户信息到本地存储
  Future<void> saveUser(User? user) async {
    currentUser.value = user;
    if (user != null) {
      await _prefs.setString(_keyUser, user.toJsonString());
    } else {
      await _prefs.remove(_keyUser);
    }
  }

  /// 保存认证 token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  /// 获取认证 token
  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  /// 清除认证信息（登出时调用）
  Future<void> clearAuth() async {
    currentUser.value = null;
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyToken);
  }

  /// 检查是否已登录
  bool get isLoggedIn => currentUser.value != null;

  /// 获取当前用户 ID
  int? get currentUserId => currentUser.value?.id;
}
