import 'package:my_app/core/error/failure.dart';
import 'package:my_app/core/error/result.dart';

import 'models/user.dart';

/// 认证仓库抽象
///
/// 定义认证功能的核心业务逻辑接口
/// 所有返回值都使用 Result 类型以确保类型安全的错误处理
abstract class AuthRepository {
  /// 用户登录
  ///
  /// 返回 [Result] 类型：
  /// - [Success] 包含登录后的用户信息
  /// - [Failure] 包含失败原因（网络错误、认证错误等）
  Future<Result<User, Failure>> login(String email, String password);

  /// 用户登出
  ///
  /// 返回 [Result] 类型：
  /// - [Success] 表示登出成功
  /// - [Failure] 包含失败原因
  Future<Result<void, Failure>> logout();

  /// 获取当前登录用户
  ///
  /// 返回 [Result] 类型：
  /// - [Success] 包含当前用户信息（如果已登录）
  /// - [Failure] 包含失败原因（如未登录）
  Future<Result<User?, Failure>> getCurrentUser();
}
