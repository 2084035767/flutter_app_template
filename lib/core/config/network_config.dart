import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 网络配置（纯静态类）
///
/// 负责管理网络相关的配置
///
/// 使用示例：
/// ```dart
/// final url = NetworkConfig.baseUrl;
/// final timeout = NetworkConfig.connectTimeout;
/// ```
class NetworkConfig {
  NetworkConfig._();

  /// API 基础 URL（从环境变量加载）
  static String baseUrl = dotenv.env['BASE_URL'] ?? 'https://api.example.com';

  /// 连接超时（毫秒）
  static const int connectTimeout = 10000;

  /// 接收超时（毫秒）
  static const int receiveTimeout = 10000;

  /// 重试间隔（毫秒）
  static const int retryDelaysTimeout = 500;

  /// 最大重试次数
  static const int retries = 3;

  /// 默认请求头
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
