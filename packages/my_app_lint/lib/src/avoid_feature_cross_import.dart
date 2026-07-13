import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';

const _errorMessage =
    'Do not import another feature\'s page/ or logic/ layer. '
    'Features should only depend on core/ or other feature\'s data/ layer.';

const _correctionMessage = '''
Cross-feature page/logic imports violate FSD boundaries.

If you need to share state between features:
  - Use a core-level signal (in core/data/storage/)
If you need to share a widget:
  - Move it to core/presentation/widgets/
If you need to share a data type:
  - Import from the other feature's data/ layer instead

Example violations:
  import 'package:my_app/features/article/page/article_list_page.dart';  // BAD
  import 'package:my_app/features/article/logic/article_view_model.dart'; // BAD

Allowed:
  import 'package:my_app/features/article/data/models/article.dart';  // OK
''';

/// A lint rule that forbids a feature from importing another feature's
/// `page/` or `logic/` directory, enforcing Feature-Sliced Design (FSD)
/// layer constraints.
///
/// A feature may import from:
///   - `core/` (shared infrastructure)
///   - Its own files
///   - Another feature's `data/` layer (models, services, repositories)
///
/// A feature must NOT import from:
///   - Another feature's `page/` layer
///   - Another feature's `logic/` layer
class AvoidFeatureCrossImport extends AnalysisRule {
  AvoidFeatureCrossImport()
    : super(
        name: 'avoid_feature_cross_import',
        description: 'Do not import another feature\'s page/ or logic/ layer.',
      );

  static const _code = LintCode(
    'avoid_feature_cross_import',
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
    registry.addImportDirective(this, visitor);
  }
}

/// Extracts the feature name from a file path like
/// `.../features/article/page/some_page.dart`.
///
/// Returns `null` if the path is not inside a feature directory.
String? _extractFeatureFromPath(String path) {
  final match = RegExp(
    r'features/([^/]+)/',
    caseSensitive: false,
  ).firstMatch(path);
  return match?.group(1);
}

/// Checks whether a URI/path targets another feature's `page/` or `logic/`
/// directory.
bool _isCrossFeaturePageOrLogic(String filePath, String currentFeature) {
  final match = RegExp(
    r'features/([^/]+)/(page|logic)/',
    caseSensitive: false,
  ).firstMatch(filePath);
  if (match == null) return false;
  return match.group(1)!.toLowerCase() != currentFeature.toLowerCase();
}

/// Extracts the resolved import URI from an [ImportDirective].
///
/// Prefers the resolved element URI (via [LibraryElement.firstFragment])
/// and falls back to the raw string literal value.
String _resolvedImportUri(ImportDirective node) {
  final libraryImport = node.libraryImport;
  if (libraryImport != null) {
    final importedLibrary = libraryImport.importedLibrary;
    if (importedLibrary != null) {
      // Use the first fragment's source URI (e.g. package:my_app/...)
      final uri = importedLibrary.firstFragment.source.uri.toString();
      if (uri.isNotEmpty) return uri;
    }
  }
  // Fallback: raw string from the import statement.
  return node.uri.stringValue ?? '';
}

class _Visitor extends SimpleAstVisitor<void> {
  final AvoidFeatureCrossImport rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  String? get _currentPath {
    final path = context.currentUnit?.file.path;
    if (path == null) return null;
    return path.replaceAll('\\', '/');
  }

  @override
  void visitImportDirective(ImportDirective node) {
    final currentPath = _currentPath;
    if (currentPath == null) return;

    final currentFeature = _extractFeatureFromPath(currentPath);
    if (currentFeature == null) return; // Not in a feature directory

    final importUri = _resolvedImportUri(node);
    if (importUri.isEmpty) return;

    if (_isCrossFeaturePageOrLogic(importUri, currentFeature)) {
      rule.reportAtNode(node);
    }
  }
}
