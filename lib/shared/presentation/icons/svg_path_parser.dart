import 'package:material_ui/material_ui.dart';

/// Builds a [Path] from SVG path data (`d`): `M m L l H h V v C c S s Q q
/// T t A a Z z`, implicit repeated commands, compact numbers (`.5`,
/// `-2.007-1.523`, `1e-3`) and compact arc flags. [FormatException] on
/// anything else (data must start with a moveto).
Path parseSvgPath(String data) => _SvgPathParser(data).parse();

final class _SvgPathParser {
  new(this._data);

  final String _data;
  int _index = 0;

  final _path = Path();
  Offset _current = Offset.zero;
  Offset _start = Offset.zero;

  /// The last control point of a C/S (or Q/T), for the reflections of S
  /// (or T).
  Offset? _cubicControl;
  Offset? _quadControl;

  static final _number = RegExp(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');

  Path parse() {
    String? command;
    while (true) {
      _skipSeparators();
      if (_index >= _data.length) break;
      final char = _data[_index];
      if (_isCommand(char) && (command != null || char.toUpperCase() == 'M')) {
        command = char;
        _index++;
      } else if (command == null || command == 'Z' || command == 'z') {
        throw FormatException('expected a command', _data, _index);
      }
      command = _run(command);
    }
    return _path;
  }

  /// Runs one segment of [command]; returns the command the next implicit
  /// numbers repeat (a moveto repeats as a lineto).
  String _run(String command) {
    var next = command;
    final relative = command == command.toLowerCase();
    Offset point(Offset offset) => relative ? _current + offset : offset;
    var cubic = false;
    var quad = false;
    switch (command.toUpperCase()) {
      case 'M':
        _current = _start = point(_pair());
        _path.moveTo(_current.dx, _current.dy);
        next = relative ? 'l' : 'L';
      case 'L':
        _current = point(_pair());
        _path.lineTo(_current.dx, _current.dy);
      case 'H':
        final x = _readNumber();
        _current = Offset(relative ? _current.dx + x : x, _current.dy);
        _path.lineTo(_current.dx, _current.dy);
      case 'V':
        final y = _readNumber();
        _current = Offset(_current.dx, relative ? _current.dy + y : y);
        _path.lineTo(_current.dx, _current.dy);
      case 'C':
        final control1 = point(_pair());
        _cubicTo(control1, point(_pair()), point(_pair()));
        cubic = true;
      case 'S':
        final control1 = _reflect(_cubicControl);
        _cubicTo(control1, point(_pair()), point(_pair()));
        cubic = true;
      case 'Q':
        _quadTo(point(_pair()), point(_pair()));
        quad = true;
      case 'T':
        _quadTo(_reflect(_quadControl), point(_pair()));
        quad = true;
      case 'A':
        final radius = Radius.elliptical(_readNumber(), _readNumber());
        final rotation = _readNumber();
        final largeArc = _readFlag();
        final clockwise = _readFlag();
        final end = point(_pair());
        _path.arcToPoint(
          end,
          radius: radius,
          rotation: rotation,
          largeArc: largeArc,
          clockwise: clockwise,
        );
        _current = end;
      default: // 'Z'
        _path.close();
        _current = _start;
    }
    if (!cubic) _cubicControl = null;
    if (!quad) _quadControl = null;
    return next;
  }

  void _cubicTo(Offset control1, Offset control2, Offset end) {
    _path.cubicTo(
      control1.dx,
      control1.dy,
      control2.dx,
      control2.dy,
      end.dx,
      end.dy,
    );
    _cubicControl = control2;
    _current = end;
  }

  void _quadTo(Offset control, Offset end) {
    _path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    _quadControl = control;
    _current = end;
  }

  /// The reflection of [control] about the current point, or the current
  /// point when the previous segment was not of the same kind.
  Offset _reflect(Offset? control) =>
      control == null ? _current : _current * 2 - control;

  Offset _pair() => Offset(_readNumber(), _readNumber());

  double _readNumber() {
    _skipSeparators();
    final match = _number.matchAsPrefix(_data, _index);
    if (match == null) {
      throw FormatException('expected a number', _data, _index);
    }
    _index = match.end;
    return double.parse(match[0]!);
  }

  bool _readFlag() {
    _skipSeparators();
    if (_index < _data.length &&
        (_data[_index] == '0' || _data[_index] == '1')) {
      return _data[_index++] == '1';
    }
    throw FormatException('expected an arc flag', _data, _index);
  }

  void _skipSeparators() {
    while (_index < _data.length && ' ,\t\n\r'.contains(_data[_index])) {
      _index++;
    }
  }

  static bool _isCommand(String char) => 'MmLlHhVvCcSsQqTtAaZz'.contains(char);
}
