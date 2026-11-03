// Reads Dart sources without the analyzer: comments, directives and the
// files their URIs point to. Shared by the architecture tests
// (test/architecture/) and the coverage gate. SDK libraries only.

import 'dart:convert';
import 'dart:io';

const _newline = 0x0A;
const _carriageReturn = 0x0D;
const _space = 0x20;
const _doubleQuote = 0x22;
const _dollar = 0x24;
const _singleQuote = 0x27;
const _openParen = 0x28;
const _closeParen = 0x29;
const _star = 0x2A;
const _slash = 0x2F;
const _semicolon = 0x3B;
const _equals = 0x3D;
const _backslash = 0x5C;
const _openBrace = 0x7B;
const _closeBrace = 0x7D;

/// An `import`, `export` or `part` directive.
final class Directive {
  const new({
    required this.keyword,
    required this.uris,
    required this.line,
    required this.endLine,
  });

  /// `import`, `export` or `part`.
  final String keyword;

  /// The URI, then the URI of each conditional configuration
  /// (`if (dart.library.io) 'io.dart'`).
  final List<String> uris;

  /// 1-based line of the keyword.
  final int line;

  /// 1-based line of the closing semicolon.
  final int endLine;
}

/// A Dart file: its text, the same text without comments, its directives.
final class DartSource {
  /// Reads [text], a whole Dart file.
  factory(String text) {
    final lexer = _Lexer(text)..scan();
    return DartSource._(
      text: text,
      code: String.fromCharCodes(lexer.code),
      directives: _directives(lexer.tokens, lexer.lineAt),
      lineStarts: lexer.lineStarts,
    );
  }

  new _({
    required this.text,
    required this.code,
    required this.directives,
    required this._lineStarts,
  });

  /// The text as read.
  final String text;

  /// [text] with every comment replaced by spaces: same length, same line
  /// breaks, string literals kept.
  final String code;

  /// The `import`, `export` and `part` directives, in order.
  final List<Directive> directives;

  final List<int> _lineStarts;

  /// The 1-based line of the character at [offset] of [text] (or [code]).
  int lineAt(int offset) => _lineOf(_lineStarts, offset);
}

/// What a URI of a directive points to.
sealed class UriTarget {
  const new();
}

/// A file of the project, by its `/`-separated path relative to the project
/// root (`lib/app/app.dart`). It may not exist, and it starts with `../`
/// when a relative URI leaves the project.
final class ProjectFile extends UriTarget {
  const new(this.path);

  final String path;
}

/// A library of the SDK: `dart:<name>`.
final class DartLibrary extends UriTarget {
  const new(this.name);

  final String name;
}

/// A package outside the project, by name (or the whole URI when it has
/// another scheme).
final class ExternalPackage extends UriTarget {
  const new(this.name);

  final String name;
}

/// Resolves [uri], written in the project file [from], to its target.
///
/// [packages] maps the packages rooted inside the project to the
/// project-relative directory of their `package:` URIs (see
/// [readPackageConfig]); any other package is external.
UriTarget resolveUri(
  String uri, {
  required String from,
  required Map<String, String> packages,
}) {
  if (uri.startsWith('dart:')) return DartLibrary(uri.substring(5));
  if (uri.startsWith('package:')) {
    final segments = uri.substring(8).split('/');
    final name = segments.first;
    final directory = packages[name];
    if (directory == null) return ExternalPackage(name);
    return ProjectFile(
      normalizePath('$directory/${segments.skip(1).join('/')}'),
    );
  }
  if (uri.contains(':')) return ExternalPackage(uri);
  final slash = from.lastIndexOf('/');
  return ProjectFile(normalizePath('${from.substring(0, slash + 1)}$uri'));
}

/// Collapses the empty, `.` and `..` segments of a `/`-separated relative
/// path; the `..` that climb above its start are kept in front.
String normalizePath(String path) {
  final segments = <String>[];
  for (final segment in path.split('/')) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..' && segments.isNotEmpty && segments.last != '..') {
      segments.removeLast();
    } else {
      segments.add(segment);
    }
  }
  return segments.join('/');
}

/// The packages of `<root>/.dart_tool/package_config.json` that live inside
/// the project, mapped to the project-relative directory of their `package:`
/// URIs (`kiveto_mobile` to `lib`, `kiveto_tool` to `tool/lib`).
///
/// Pub writes a relative `rootUri` for path packages; an absolute one (the
/// pub cache, the SDK) is outside the project. Throws a [FileSystemException]
/// when the file is missing and a [FormatException] when it is not a package
/// configuration.
Map<String, String> readPackageConfig(String root) {
  final json = jsonDecode(
    File('$root/.dart_tool/package_config.json').readAsStringSync(),
  );
  if (json case {'packages': final List<Object?> packages}) {
    return {
      for (final package in packages)
        if (package
            case {
              'name': final String name,
              'rootUri': final String rootUri,
              'packageUri': final String packageUri,
            }
            when !rootUri.contains(':'))
          if (normalizePath('.dart_tool/$rootUri/$packageUri')
              case final directory when !directory.startsWith('..'))
            name: directory,
    };
  }
  throw const FormatException('no "packages" list');
}

/// The `/`-separated paths, relative to [root], of the `.dart` files under
/// `<root>/<directory>`, sorted. The files of `.dart_tool` folders (pub's
/// and the build tools' output) are skipped, any other hidden folder or
/// file is listed: it can still be imported. A missing directory has no
/// file.
List<String> listDartFiles(String root, String directory) {
  final base = Directory('$root/$directory');
  if (!base.existsSync()) return const [];
  final skip = base.path.length + 1;
  return [
    for (final entity in base.listSync(recursive: true))
      if (entity is File && entity.path.endsWith('.dart'))
        if (entity.path.substring(skip).replaceAll(r'\', '/') case final path
            when !path.split('/').reversed.skip(1).contains('.dart_tool'))
          '$directory/$path',
  ]..sort();
}

int _lineOf(List<int> lineStarts, int offset) {
  var low = 0;
  var high = lineStarts.length - 1;
  while (low < high) {
    final middle = (low + high + 1) >> 1;
    if (lineStarts[middle] <= offset) {
      low = middle;
    } else {
      high = middle - 1;
    }
  }
  return low + 1;
}

/// The directives among [tokens]: an `import`, `export` or `part` keyword
/// outside any brace or parenthesis, followed by a string literal. The
/// strings outside parentheses up to the semicolon are its URIs (those in
/// parentheses are the conditions of conditional imports).
List<Directive> _directives(
  List<_Token> tokens,
  int Function(int offset) lineAt,
) {
  final directives = <Directive>[];
  var depth = 0;
  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    depth += token.depthChange;
    final next = i + 1 < tokens.length ? tokens[i + 1] : null;
    if (depth != 0 ||
        !token.isKeyword ||
        next == null ||
        next.kind != _TokenKind.string) {
      continue;
    }
    final uris = <String>[];
    var nesting = 0;
    var end = token.offset;
    for (i++; i < tokens.length; i++) {
      final part = tokens[i];
      end = part.offset;
      if (part.kind == _TokenKind.semicolon) break;
      nesting += part.depthChange;
      if (part.kind == _TokenKind.string && nesting == 0) uris.add(part.text);
    }
    directives.add(
      Directive(
        keyword: token.text,
        uris: uris,
        line: lineAt(token.offset),
        endLine: lineAt(end),
      ),
    );
  }
  return directives;
}

enum _TokenKind { word, string, open, close, semicolon, equals }

final class _Token {
  const new(this.kind, this.text, this.offset);

  final _TokenKind kind;

  /// The word, or the value of the string literal (an escaped character
  /// stands for itself, interpolations are kept as written).
  final String text;
  final int offset;

  int get depthChange => switch (kind) {
    _TokenKind.open => 1,
    _TokenKind.close => -1,
    _ => 0,
  };

  bool get isKeyword =>
      kind == _TokenKind.word &&
      (text == 'import' || text == 'export' || text == 'part');
}

/// Walks a Dart file once: blanks its comments into [code], records the
/// start of each line and the tokens the directives need (words, string
/// literals, braces, parentheses, semicolons, `=`) outside interpolations.
final class _Lexer {
  new(this.source) : code = source.codeUnits.toList();

  final String source;
  final List<int> code;
  final List<_Token> tokens = [];
  final List<int> lineStarts = [0];
  var _i = 0;

  /// Above zero while inside a `${…}` interpolation: no token is recorded.
  var _nesting = 0;

  int lineAt(int offset) => _lineOf(lineStarts, offset);

  void scan() {
    for (var i = 0; i < source.length; i++) {
      if (source.codeUnitAt(i) == _newline) lineStarts.add(i + 1);
    }
    _scanCode();
  }

  int _at(int index) => index < source.length ? source.codeUnitAt(index) : -1;

  void _add(_TokenKind kind, String text, int offset) {
    if (_nesting == 0) tokens.add(_Token(kind, text, offset));
  }

  /// Scans code up to the end of the file or, inside an interpolation, up to
  /// its closing brace.
  void _scanCode() {
    var braces = 0;
    while (_i < source.length) {
      final unit = source.codeUnitAt(_i);
      final next = _at(_i + 1);
      if (unit == _slash && next == _slash) {
        _skipLineComment();
      } else if (unit == _slash && next == _star) {
        _skipBlockComment();
      } else if (unit == _singleQuote || unit == _doubleQuote) {
        _scanString(_i, raw: false);
      } else if (_isWordStart(unit)) {
        _scanWord();
      } else if (unit == _closeBrace && _nesting > 0 && braces == 0) {
        _i++;
        return;
      } else {
        braces += switch (unit) {
          _openBrace => 1,
          _closeBrace => -1,
          _ => 0,
        };
        final kind = switch (unit) {
          _openBrace || _openParen => _TokenKind.open,
          _closeBrace || _closeParen => _TokenKind.close,
          _semicolon => _TokenKind.semicolon,
          // `final part = 'x';`, `String get export => 'y';`: the keyword is
          // then followed by this token, not by the string.
          _equals => _TokenKind.equals,
          _ => null,
        };
        if (kind != null) _add(kind, String.fromCharCode(unit), _i);
        _i++;
      }
    }
  }

  void _scanWord() {
    final start = _i;
    while (_i < source.length && _isWordPart(source.codeUnitAt(_i))) {
      _i++;
    }
    final word = source.substring(start, _i);
    final unit = _at(_i);
    if (word == 'r' && (unit == _singleQuote || unit == _doubleQuote)) {
      _scanString(start, raw: true);
    } else {
      _add(_TokenKind.word, word, start);
    }
  }

  /// Scans a string literal whose quote is at the current position; [start]
  /// is where its token starts (the `r` of a raw string).
  void _scanString(int start, {required bool raw}) {
    final quote = source.codeUnitAt(_i);
    final triple = _at(_i + 1) == quote && _at(_i + 2) == quote;
    _i += triple ? 3 : 1;
    final value = StringBuffer();
    while (_i < source.length) {
      final unit = source.codeUnitAt(_i);
      if (unit == quote &&
          (!triple || (_at(_i + 1) == quote && _at(_i + 2) == quote))) {
        _i += triple ? 3 : 1;
        break;
      }
      if (!triple && unit == _newline) break;
      if (!raw && unit == _backslash && _i + 1 < source.length) {
        value.writeCharCode(source.codeUnitAt(_i + 1));
        _i += 2;
      } else if (!raw && unit == _dollar && _at(_i + 1) == _openBrace) {
        final from = _i;
        _i += 2;
        _nesting++;
        _scanCode();
        _nesting--;
        value.write(source.substring(from, _i));
      } else {
        value.writeCharCode(unit);
        _i++;
      }
    }
    _add(_TokenKind.string, value.toString(), start);
  }

  void _skipLineComment() {
    while (_i < source.length && source.codeUnitAt(_i) != _newline) {
      _blank(_i++);
    }
  }

  /// Block comments nest in Dart.
  void _skipBlockComment() {
    var depth = 0;
    while (_i < source.length) {
      final unit = source.codeUnitAt(_i);
      final next = _at(_i + 1);
      if (unit == _slash && next == _star) {
        depth++;
        _blank(_i++);
        _blank(_i++);
      } else if (unit == _star && next == _slash) {
        depth--;
        _blank(_i++);
        _blank(_i++);
        if (depth == 0) return;
      } else {
        _blank(_i++);
      }
    }
  }

  void _blank(int index) {
    final unit = code[index];
    if (unit != _newline && unit != _carriageReturn) code[index] = _space;
  }
}

bool _isWordStart(int unit) =>
    (unit >= 0x61 && unit <= 0x7A) || // a-z
    (unit >= 0x41 && unit <= 0x5A) || // A-Z
    unit == 0x5F || // _
    unit == _dollar;

bool _isWordPart(int unit) =>
    _isWordStart(unit) || (unit >= 0x30 && unit <= 0x39); // 0-9
