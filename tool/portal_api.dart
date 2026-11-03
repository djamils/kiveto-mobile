// The Portal API contract commands of the make targets:
//
//   dart tool/portal_api.dart sync <backend-dir> <ref>   (make api-sync)
//   dart tool/portal_api.dart stamp                      (make api-generate)
//   dart tool/portal_api.dart check                      (make api-check)
//
// Run from the repository root. Exit 0 done, 1 failed (every cause printed
// on stderr with the command that fixes it), 64 usage error.
//
// A thin entry point over package:kiveto_tool/portal_api.dart (tool/lib/,
// SDK libraries only, tested by test/tool/), which documents the commands.

import 'dart:convert';
import 'dart:io';

import 'package:kiveto_tool/portal_api.dart';

Future<void> main(List<String> args) async {
  stdout.encoding = utf8;
  stderr.encoding = utf8;
  exitCode = await runPortalApi(
    args,
    root: Directory.current.path,
    out: stdout,
    err: stderr,
  );
}
