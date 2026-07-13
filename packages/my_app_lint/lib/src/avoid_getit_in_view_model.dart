import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

const _errorMessage =
    'Avoid using getIt() in ViewModels. '
    'Use constructor injection instead.';

const _correctionMessage = '''
ViewModels should receive dependencies via constructor injection,
not by calling getIt() directly.

// BAD
class ArticleViewModel {
  final repo = getIt<ArticleRepository>();
}

// GOOD
class ArticleViewModel {
  final ArticleRepository repo;
  ArticleViewModel(this.repo);
}
''';

/// A lint rule that forbids calling `getIt()` inside ViewModel files
/// (files under `features/*/logic/`).
///
/// ViewModels should receive dependencies via constructor injection,
/// which makes them testable and avoids hidden dependencies.
class AvoidGetItInViewModel extends AnalysisRule {
  AvoidGetItInViewModel()
    : super(
        name: 'avoid_getit_in_view_model',
        description:
            'Avoid using getIt() in ViewModels. '
            'Use constructor injection instead.',
      );

  static const _code = LintCode(
    'avoid_getit_in_view_model',
    _errorMessage,
    correctionMessage: _correctionMessage,
  );

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidGetItInViewModel rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  bool _isInLogicDir() {
    final path = context.currentUnit?.file.path;
    if (path == null) return false;
    final normalized = path.replaceAll('\\', '/');
    return RegExp(r'features/[^/]+/logic/').hasMatch(normalized);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'getIt') return;
    if (!_isInLogicDir()) return;
    rule.reportAtNode(node);
  }
}
