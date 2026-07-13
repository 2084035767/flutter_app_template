import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/avoid_getit_in_view_model.dart';
import 'src/avoid_feature_cross_import.dart';

final plugin = MyAppLintPlugin();

class MyAppLintPlugin extends Plugin {
  @override
  String get name => 'my_app_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(AvoidGetItInViewModel());
    registry.registerLintRule(AvoidFeatureCrossImport());
  }
}
