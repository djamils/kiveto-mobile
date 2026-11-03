// The SDK-only Dart scanner shared by the architecture tests and the
// coverage gate (tool/lib/dart_source.dart).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_tool/dart_source.dart';

/// The URIs of [source]'s directives, with their keyword and lines.
List<String> _directives(String source) => [
  for (final d in DartSource(source).directives)
    '${d.keyword} ${d.uris.join(' | ')} @${d.line}-${d.endLine}',
];

void main() {
  group('DartSource.code', () {
    test('blanks line, doc and nested block comments, keeping the length '
        'and the line breaks', () {
      const text =
          '/// Doc.\n'
          'var a = 1; // trailing\r\n'
          '/* outer /* inner */ still\n'
          'comment */ var b = 2;\n';
      final code = DartSource(text).code;
      expect(code.length, text.length);
      expect(code.split('\n').length, text.split('\n').length);
      expect(code, contains('var a = 1;'));
      expect(code, contains('\r\n'));
      expect(code, contains('var b = 2;'));
      for (final gone in ['Doc', 'trailing', 'outer', 'inner', 'comment']) {
        expect(code, isNot(contains(gone)));
      }
    });

    test('keeps comment markers inside string literals', () {
      const text =
          "var url = 'http://example.com';\n"
          'var block = "/* not a comment */";\n'
          "var raw = r'C:\\dir\\' // gone\n"
          '  ;\n'
          "var triple = '''\n"
          '// still text\n'
          "''';\n"
          'var escaped = "say \\"//\\"";\n';
      final code = DartSource(text).code;
      expect(code, contains('http://example.com'));
      expect(code, contains('/* not a comment */'));
      expect(code, contains(r"r'C:\dir\'"));
      expect(code, isNot(contains('gone')));
      expect(code, contains('// still text'));
      expect(code, contains(r'"say \"//\""'));
    });

    test('follows interpolations holding quotes, braces and comments', () {
      const text =
          r"var a = '${m['k']} ${ {1: 2}[1] /* c */ } $b'; // gone"
          '\n'
          r'''var c = "${"nested ${'deep'}"}";''';
      final code = DartSource(text).code;
      expect(code, contains(r"${m['k']}"));
      expect(code, isNot(contains('/* c */')));
      expect(code, isNot(contains('gone')));
      expect(code, contains(r'''"${"nested ${'deep'}"}"'''));
    });

    test('stops an unterminated string at the end of its line and an '
        'unterminated comment at the end of the file', () {
      const text =
          "var a = 'open\n"
          '// gone\n'
          '/* never closed';
      final code = DartSource(text).code;
      expect(code, startsWith("var a = 'open\n"));
      expect(code, isNot(contains('gone')));
      expect(code, isNot(contains('never')));
    });
  });

  group('DartSource.directives', () {
    test('reads import, export and part with their lines', () {
      expect(
        _directives(
          "import 'dart:async';\n"
          'import "package:a/a.dart" as a show A, B hide C;\n'
          "export 'src/b.dart';\n"
          "part 'c.dart';\n"
          "part of 'd.dart';\n",
        ),
        [
          'import dart:async @1-1',
          'import package:a/a.dart @2-2',
          'export src/b.dart @3-3',
          'part c.dart @4-4',
        ],
      );
    });

    test('reads a directive over several lines, deferred and raw URIs', () {
      expect(
        _directives(
          '// header\n'
          '\n'
          "import r'package:a/a.dart'\n"
          '    deferred as a\n'
          '    show A;\n',
        ),
        ['import package:a/a.dart @3-5'],
      );
    });

    test('keeps every URI of a conditional import, not the conditions', () {
      expect(
        _directives(
          "import 'stub.dart'\n"
          "    if (dart.library.io) 'io.dart'\n"
          "    if (dart.library.js_interop == 'true') 'web.dart';\n"
          "export 'a.dart' if (dart.library.ui) 'b.dart';\n",
        ),
        [
          'import stub.dart | io.dart | web.dart @1-3',
          'export a.dart | b.dart @4-4',
        ],
      );
    });

    test('ignores the keywords in comments, strings, bodies and calls', () {
      expect(
        _directives(
          "// import 'commented.dart';\n"
          "/* export 'block.dart'; */\n"
          "const text = 'import \"x.dart\";';\n"
          "class A { void part() { import('a'); } }\n"
          "void f() => part('b');\n"
          'final import = 1;\n',
        ),
        isEmpty,
      );
    });

    test('ignores top-level variables and getters named like a keyword', () {
      expect(
        _directives(
          "final part = 'x.dart';\n"
          "String get export => 'y.dart';\n"
          "var import = 'z.dart';\n"
          "import 'kept.dart';\n",
        ),
        ['import kept.dart @4-4'],
      );
    });

    test('ends a directive without semicolon at the end of the file', () {
      expect(_directives("import 'a.dart'\n\n"), ['import a.dart @1-1']);
    });
  });

  test('lineAt gives the 1-based line of an offset', () {
    final source = DartSource('a\nbc\n\nd');
    expect([0, 1, 2, 4, 5, 6].map(source.lineAt).toList(), [1, 1, 2, 2, 3, 4]);
  });

  group('resolveUri', () {
    const packages = {'kiveto_mobile': 'lib', 'kiveto_tool': 'tool/lib'};

    UriTarget resolve(String uri, [String from = 'lib/features/a/b.dart']) =>
        resolveUri(uri, from: from, packages: packages);

    String describe(UriTarget target) => switch (target) {
      ProjectFile(:final path) => 'file $path',
      DartLibrary(:final name) => 'dart $name',
      ExternalPackage(:final name) => 'package $name',
    };

    test('classifies SDK libraries and outside packages', () {
      expect(describe(resolve('dart:io')), 'dart io');
      expect(describe(resolve('package:dio/dio.dart')), 'package dio');
      expect(
        describe(resolve('https://x.dev/a.dart')),
        'package https://x.dev/a.dart',
      );
    });

    test('resolves the packages of the project to project files', () {
      expect(
        describe(resolve('package:kiveto_mobile/shared/domain/clock.dart')),
        'file lib/shared/domain/clock.dart',
      );
      expect(
        describe(resolve('package:kiveto_tool/devices.dart')),
        'file tool/lib/devices.dart',
      );
    });

    test('resolves relative URIs from the importing file', () {
      expect(describe(resolve('c.dart')), 'file lib/features/a/c.dart');
      expect(describe(resolve('../../core/x.dart')), 'file lib/core/x.dart');
      expect(describe(resolve('./d/e.dart')), 'file lib/features/a/d/e.dart');
      expect(describe(resolve('x.dart', 'main.dart')), 'file x.dart');
      expect(describe(resolve('../../x.dart', 'lib/a.dart')), 'file ../x.dart');
    });
  });

  test('normalizePath collapses ., .. and empty segments', () {
    expect(normalizePath('a/./b/../c'), 'a/c');
    expect(normalizePath('//a//b/'), 'a/b');
    expect(normalizePath('../x'), '../x');
    expect(normalizePath('a/../../x/../../y'), '../../y');
  });

  group('with a temporary project', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('kiveto_dart_source_');
      addTearDown(() => root.deleteSync(recursive: true));
    });

    void write(String path, String content) {
      File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    }

    test('readPackageConfig keeps the packages rooted in the project', () {
      write('.dart_tool/package_config.json', '''
{
  "configVersion": 2,
  "packages": [
    {"name": "async", "rootUri": "file:///C:/pub/async-2.13.1", "packageUri": "lib/"},
    {"name": "kiveto_tool", "rootUri": "../tool", "packageUri": "lib/"},
    {"name": "sibling", "rootUri": "../../sibling", "packageUri": "lib/"},
    {"name": "no_package_uri", "rootUri": "../x"},
    {"name": "kiveto_mobile", "rootUri": "../", "packageUri": "lib/"}
  ]
}''');
      expect(readPackageConfig(root.path), {
        'kiveto_tool': 'tool/lib',
        'kiveto_mobile': 'lib',
      });
    });

    test('readPackageConfig throws on a missing or foreign file', () {
      expect(
        () => readPackageConfig(root.path),
        throwsA(isA<FileSystemException>()),
      );
      write('.dart_tool/package_config.json', '{"configVersion": 2}');
      expect(
        () => readPackageConfig(root.path),
        throwsA(isA<FormatException>()),
      );
    });

    test('listDartFiles lists the Dart files, sorted, without the .dart_tool '
        'folders but with any other hidden folder or file', () {
      write('lib/b.dart', '');
      write('lib/a/z.dart', '');
      write('lib/a/readme.md', '');
      write('lib/.hidden/x.dart', '');
      write('lib/a/.gen/y.dart', '');
      write('lib/a/.draft.dart', '');
      write('lib/.dart_tool/cache.dart', '');
      write('lib/a/.dart_tool/build/entry.dart', '');
      expect(listDartFiles(root.path, 'lib'), [
        'lib/.hidden/x.dart',
        'lib/a/.draft.dart',
        'lib/a/.gen/y.dart',
        'lib/a/z.dart',
        'lib/b.dart',
      ]);
      expect(listDartFiles(root.path, 'missing'), isEmpty);
    });
  });
}
