// Writes the normalised build copy of the Portal API contract that tonik
// generates the client from (`make api-generate`):
//
//   dart tool/normalize_contract.dart contracts/portal.v1.yaml \
//     tool/api_generator/tonik.yaml build/kiveto_portal_api/portal.v1.yaml
//
// Exit 0 copy written, 1 contract refused (a contract item without a
// readable name in tonik.yaml, a schema that cannot be rewritten, invalid
// YAML, a missing file), 64 usage error.
//
// A thin entry point over package:kiveto_tool/contract_normalizer.dart
// (tool/lib/, tested by test/tool/), which documents the normalisation.

import 'dart:convert';
import 'dart:io';

import 'package:kiveto_tool/contract_normalizer.dart';

void main(List<String> args) {
  stdout.encoding = utf8;
  stderr.encoding = utf8;
  exitCode = runNormalizeContract(args, out: stdout, err: stderr);
}
