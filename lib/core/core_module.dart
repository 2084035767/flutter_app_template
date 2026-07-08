// lib/core/core_module.dart
import 'package:shared_preferences/shared_preferences.dart';

/// 核心模块 - 提供应用级基础设施依赖
abstract class CoreModule {
  /// SharedPreferences 实例（预解析）
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
