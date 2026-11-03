// The contract normaliser (tool/lib/contract_normalizer.dart): small
// synthetic contracts for each rule, then the real contracts/portal.v1.yaml
// with tool/api_generator/tonik.yaml.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_tool/contract_normalizer.dart';

/// Every kind of schema: response-only (direct, transitive, through
/// components.responses, quoted dotted keys), shared with a request,
/// request-only (body through components.requestBodies, operation and path
/// parameters), already declaring `required`, without properties, unused.
const _contract = r'''
openapi: 3.2.0
info:
  title: Synthetic
paths:
  /me:
    summary: The owner.
    parameters:
      -
        name: x
        in: query
        schema:
          $ref: '#/components/schemas/PathFilter'
    get:
      operationId: getMe
      tags:
        - Account
      parameters:
        -
          name: q
          in: query
          schema:
            $ref: '#/components/schemas/Query'
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Me'
        '404':
          $ref: '#/components/responses/Problem'
        '410':
          $ref: 'https://example.com/other.yaml#/Gone'
    patch:
      operationId: updateMe
      tags:
        - Account
      requestBody:
        $ref: '#/components/requestBodies/PatchBody'
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Me.View'
components:
  schemas:
    # A comment line, then a blank one.

    Me:
      type: object
      properties:
        id:
          type: string
        email:
          type:
            - string
            - 'null'
        address:
          anyOf:
            -
              $ref: '#/components/schemas/AddressView'
            -
              type: 'null'
        shared:
          $ref: '#/components/schemas/Shared'
        declared:
          $ref: '#/components/schemas/Declared'
        empty:
          $ref: '#/components/schemas/Empty'
        weird:
          $ref: '#/components/schemas/Weird.Name'
    AddressView:
      type: object
      properties:
        city:
          type: string
    'Me.View':
      type: object
      properties:
        id:
          type: string
    "Weird.Name":
      type: object
      properties:
        '@id':
          type: string
        'null':
          type: string
        "it's":
          type: string
    Shared:
      type: object
      properties:
        name:
          type: string
    Patch:
      type: object
      properties:
        firstName:
          type:
            - string
            - 'null'
        shared:
          $ref: '#/components/schemas/Shared'
    Query:
      type: object
      properties:
        page:
          type: integer
    PathFilter:
      type: object
      properties:
        kind:
          type: string
    Declared:
      type: object
      required:
        - id
      properties:
        id:
          type: string
        note:
          type: string
    Empty:
      type: string
    Error:
      type: object
      properties:
        type:
          type: string
    Unused:
      type: object
      properties:
        id:
          type: string
  responses:
    Problem:
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Error'
  requestBodies:
    PatchBody:
      content:
        application/merge-patch+json:
          schema:
            $ref: '#/components/schemas/Patch'
tags:
  -
    name: Account
  -
    name: Docs
''';

const _config = '''
nameOverrides:
  tags:
    Account: Account
    Docs: Documents
  operations:
    getMe: getMe
    updateMe: updateMe
  schemas:
    Me.View: MeView
    Weird.Name: WeirdName
''';

/// [_contract] as the normaliser must write it.
final String _normalised = _contract
    .replaceFirst(
      '''
    Me:
      type: object
''',
      '''
    Me:
      type: object
      required:
        - id
        - email
        - address
        - shared
        - declared
        - empty
        - weird
''',
    )
    .replaceFirst(
      '''
    AddressView:
      type: object
''',
      '''
    AddressView:
      type: object
      required:
        - city
''',
    )
    .replaceFirst(
      '''
    'Me.View':
      type: object
''',
      '''
    'Me.View':
      type: object
      required:
        - id
''',
    )
    .replaceFirst(
      '''
    "Weird.Name":
      type: object
''',
      '''
    "Weird.Name":
      type: object
      required:
        - '@id'
        - 'null'
        - 'it''s'
''',
    )
    .replaceFirst(
      '''
    Error:
      type: object
''',
      '''
    Error:
      type: object
      required:
        - type
''',
    );

typedef _Run = ({int code, String out, String err});

_Run _main(List<String> args) {
  final out = StringBuffer();
  final err = StringBuffer();
  final code = runNormalizeContract(args, out: out, err: err);
  return (code: code, out: out.toString(), err: err.toString());
}

Matcher _refused(Object message) => throwsA(
  isA<NormalizationException>().having(
    (error) => error.message,
    'message',
    message,
  ),
);

void main() {
  group('normalizeContract', () {
    test('adds required to the response-only schemas only', () {
      final result = normalizeContract(_contract, _config);

      expect(result.text, _normalised);
      expect(result.rewritten, {
        'Me',
        'AddressView',
        'Me.View',
        'Weird.Name',
        'Error',
      });
      expect(result.declared, {'Declared'});
      expect(result.requestSchemas, {'Patch', 'Shared', 'Query', 'PathFilter'});
    });

    test('keeps the CRLF line endings of a CRLF contract', () {
      final result = normalizeContract(
        _contract.replaceAll('\n', '\r\n'),
        _config,
      );

      expect(result.text, _normalised.replaceAll('\n', '\r\n'));
      expect(result.rewritten, hasLength(5));
    });

    test('is idempotent', () {
      final once = normalizeContract(_contract, _config);
      final twice = normalizeContract(once.text, _config);

      expect(twice.text, once.text);
      expect(twice.rewritten, isEmpty);
      expect(twice.declared, {...once.rewritten, ...once.declared});
      expect(twice.requestSchemas, once.requestSchemas);
    });

    test('refuses contract items without a readable name, per section', () {
      const config = '''
nameOverrides:
  tags:
    Account: Account
  operations:
    getMe: getMe
''';

      expect(
        () => normalizeContract(
          _contract,
          config,
          configName: 'tool/api_generator/tonik.yaml',
        ),
        _refused(
          'contract items without a readable name (tonik would derive one '
          'from the route or the schema key):\n'
          '  nameOverrides.operations: updateMe - add a readable name to '
          'nameOverrides.operations of tool/api_generator/tonik.yaml\n'
          '  nameOverrides.tags: Docs - add a readable name to '
          'nameOverrides.tags of tool/api_generator/tonik.yaml\n'
          '  nameOverrides.schemas: Me.View, Weird.Name - add a readable name '
          'to nameOverrides.schemas of tool/api_generator/tonik.yaml',
        ),
      );
    });

    test('a configuration without nameOverrides names nothing', () {
      expect(
        () => normalizeContract(_contract, 'logLevel: warn\n'),
        _refused(
          allOf(
            contains('nameOverrides.operations: getMe, updateMe - '),
            contains('of tonik.yaml'),
          ),
        ),
      );
    });

    test('refuses a selected schema it cannot rewrite', () {
      final contract = _contract
          .replaceFirst(
            '''
    AddressView:
      type: object
      properties:
        city:
          type: string
''',
            '''
    AddressView: {type: object, properties: {city: {type: string}}}
''',
          )
          .replaceFirst(
            '''
    Error:
      type: object
''',
            '''
    Error:
      type: object # problem+json
''',
          );

      expect(
        () => normalizeContract(contract, _config),
        _refused(
          'cannot add `required` to the response-only schemas AddressView, '
          'Error: no "      type: object" line right under their key in '
          'components.schemas',
        ),
      );
    });

    test('rewrites only inside components.schemas', () {
      const contract = r'''
paths:
  /x:
    get:
      operationId: getX
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/X'
x-notes:
    X:
      type: object
components:
  responses:
    X:
      type: object
  schemas:
    X:
      type: object
      properties:
        a:
          type: string
''';

      final result = normalizeContract(
        contract,
        'nameOverrides: {operations: {getX: getX}}',
      );

      expect(
        result.text,
        contract.replaceFirst(
          '      properties:\n',
          '      required:\n        - a\n      properties:\n',
        ),
      );
    });

    test('a refusal reads as its message', () {
      expect('${const NormalizationException('why')}', 'why');
    });

    test('refuses a document that is not YAML', () {
      expect(
        () => normalizeContract('a: [', _config),
        _refused(startsWith('the contract is not valid YAML: ')),
      );
      expect(
        () => normalizeContract(_contract, 'a: ['),
        _refused(startsWith('tonik.yaml is not valid YAML: ')),
      );
    });
  });

  group('runNormalizeContract', () {
    late Directory temp;

    setUp(() {
      temp = Directory.systemTemp.createTempSync('kiveto_normaliser_');
      addTearDown(() => temp.deleteSync(recursive: true));
      File('${temp.path}/portal.v1.yaml').writeAsStringSync(_contract);
      File('${temp.path}/tonik.yaml').writeAsStringSync(_config);
    });

    test('writes the copy, creating its folders, and says what it did', () {
      final out = '${temp.path}/build/kiveto_portal_api/portal.v1.yaml';

      final result = _main([
        '${temp.path}/portal.v1.yaml',
        '${temp.path}/tonik.yaml',
        out,
      ]);

      expect(result.code, 0, reason: result.err);
      expect(File(out).readAsStringSync(), _normalised);
      expect(
        result.out,
        'required added to 5 response-only schemas (1 already declared it; '
        'request schemas untouched: 4)\n',
      );
    });

    test('a refused contract: exit 1, the reason, nothing written', () {
      File('${temp.path}/tonik.yaml').writeAsStringSync('logLevel: warn\n');
      final out = '${temp.path}/out.yaml';

      final result = _main([
        '${temp.path}/portal.v1.yaml',
        '${temp.path}/tonik.yaml',
        out,
      ]);

      expect(result.code, 1);
      expect(result.err, contains('without a readable name'));
      expect(File(out).existsSync(), isFalse);
    });

    test('a missing input: exit 1, named', () {
      final missing = '${temp.path}/nope.yaml';

      final result = _main([
        missing,
        '${temp.path}/tonik.yaml',
        '${temp.path}/out.yaml',
      ]);

      expect(result.code, 1);
      expect(result.err, '$missing not found\n');
    });

    test('wrong arguments: exit 64 with the usage', () {
      final result = _main(['contract.yaml']);

      expect(result.code, 64);
      expect(
        result.err,
        startsWith('usage: dart tool/normalize_contract.dart'),
      );
    });
  });

  group('the real contract', () {
    final contract = File('contracts/portal.v1.yaml').readAsStringSync();
    final config = File('tool/api_generator/tonik.yaml').readAsStringSync();

    test('names every operation, tag and dotted schema in tonik.yaml', () {
      expect(() => normalizeContract(contract, config), returnsNormally);
    });

    test("only inserts `required:` lists, listing each schema's "
        'properties, into response-only schemas', () {
      final result = normalizeContract(contract, config);

      expect(result.rewritten, isNotEmpty);
      expect(result.requestSchemas, isNotEmpty);
      expect(result.rewritten.intersection(result.requestSchemas), isEmpty);
      expect(result.rewritten, containsAll(['Me', 'AccountView', 'Error']));
      expect(
        result.requestSchemas,
        containsAll(['MeUpdate.jsonMergePatch', 'AppointmentBooking']),
      );

      // Every line of the contract is kept, in order: the others are
      // inserted, each under its schema key.
      final original = contract.split('\n');
      final inserted = <String, List<String>>{};
      var kept = 0;
      String? schema;
      for (final line in result.text.split('\n')) {
        if (kept < original.length && line == original[kept]) {
          kept++;
          if (line.startsWith('    ') && !line.startsWith('     ')) {
            schema = line.trim().substring(0, line.trim().length - 1);
          }
        } else {
          (inserted[schema!] ??= []).add(line);
        }
      }
      expect(kept, original.length);
      expect(inserted.keys.toSet(), result.rewritten);

      // Each insertion is the list of the schema's properties, in order.
      for (final MapEntry(key: name, value: lines) in inserted.entries) {
        final header = original.indexOf('    $name:');
        final properties = <String>[];
        for (
          var i = original.indexOf('      properties:', header) + 1;
          i < original.length && original[i].startsWith('        ');
          i++
        ) {
          if (!original[i].startsWith('         ')) {
            properties.add(original[i].trim().replaceFirst(RegExp(r':$'), ''));
          }
        }
        expect(lines, [
          '      required:',
          for (final property in properties) '        - $property',
        ], reason: name);
      }
    });

    test('is idempotent, the output parsing again as YAML', () {
      final once = normalizeContract(contract, config);
      final twice = normalizeContract(once.text, config);

      expect(twice.text, once.text);
      expect(twice.rewritten, isEmpty);
      expect(twice.declared, containsAll(once.rewritten));
    });
  });
}
