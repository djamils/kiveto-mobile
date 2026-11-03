// Picks the device `make start` runs the app on.
//
// Reads the JSON that `flutter devices --machine` prints, on stdin (Git Bash
// has no JSON tool, so scripts/start.sh keeps the control flow and asks this
// script for the answer).
//
//   dart tool/devices.dart --platform <android|ios>
//     exit 0: the only connected device of the platform; prints its id
//     exit 2: no device of the platform; prints nothing
//     exit 3: several devices of the platform; prints "<id>\t<name>" each
//
//   dart tool/devices.dart --platform <android|ios> --device <id or name>
//     exit 0: flutter lists that device (any platform); prints its id
//     exit 2: it does not; prints "<id>\t<name>" for every listed device
//
//   exit 1: invalid arguments or input, explained on stderr.
//
// A thin entry point over package:kiveto_tool/devices.dart (tool/lib/, SDK
// libraries only, tested by test/tool/). It runs after `pub get`, which
// scripts/start.sh does first: the package resolves through the root
// .dart_tool/package_config.json.

import 'dart:io';

import 'package:kiveto_tool/devices.dart';

Future<void> main(List<String> args) async {
  exitCode = await pickDevice(args, input: stdin, out: stdout, err: stderr);
}
